--------------------------------------------------------
--  DDL for Package Body WMS_TASK_DISPATCH_PUT_AWAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_DISPATCH_PUT_AWAY" AS
  /* $Header: WMSTKPTB.pls 120.26.12010000.29 2012/06/07 13:50:02 ssingams ship $ */


  -- Global constant holding the package name
  g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_Task_Dispatch_put_away';

  /* FP-J Lot/Serial Support Enhancement
   * Record type to store information for one serial number. This is used for
   * inserting MTL_SERIAL_NUMBERS for the serial numbers in the LPN
   */
  TYPE msn_attribute_rec_tp IS RECORD(
      serial_number             mtl_serial_numbers.serial_number%TYPE
    , to_serial_number          mtl_serial_numbers.serial_number%TYPE
    , vendor_serial_number      mtl_serial_numbers.vendor_serial_number%TYPE
    , vendor_lot_number         mtl_serial_numbers.vendor_lot_number%TYPE
    , parent_serial_number      mtl_serial_numbers.parent_serial_number%TYPE
    , origination_date          mtl_serial_numbers.origination_date%TYPE
    , end_item_unit_number      mtl_serial_numbers.end_item_unit_number%TYPE
    , territory_code            mtl_serial_numbers.territory_code%TYPE
    , time_since_new            mtl_serial_numbers.time_since_new%TYPE
    , cycles_since_new          mtl_serial_numbers.cycles_since_new%TYPE
    , time_since_overhaul       mtl_serial_numbers.time_since_overhaul%TYPE
    , cycles_since_overhaul     mtl_serial_numbers.cycles_since_overhaul%TYPE
    , time_since_repair         mtl_serial_numbers.time_since_repair%TYPE
    , cycles_since_repair       mtl_serial_numbers.cycles_since_repair%TYPE
    , time_since_visit          mtl_serial_numbers.time_since_visit%TYPE
    , cycles_since_visit        mtl_serial_numbers.cycles_since_visit%TYPE
    , time_since_mark           mtl_serial_numbers.time_since_mark%TYPE
    , cycles_since_mark         mtl_serial_numbers.cycles_since_mark%TYPE
    , number_of_repairs         mtl_serial_numbers.number_of_repairs%TYPE
    , serial_attribute_category mtl_serial_numbers.serial_attribute_category%TYPE
    , c_attribute1              mtl_serial_numbers.c_attribute1%TYPE
    , c_attribute2              mtl_serial_numbers.c_attribute2%TYPE
    , c_attribute3              mtl_serial_numbers.c_attribute3%TYPE
    , c_attribute4              mtl_serial_numbers.c_attribute4%TYPE
    , c_attribute5              mtl_serial_numbers.c_attribute5%TYPE
    , c_attribute6              mtl_serial_numbers.c_attribute6%TYPE
    , c_attribute7              mtl_serial_numbers.c_attribute7%TYPE
    , c_attribute8              mtl_serial_numbers.c_attribute8%TYPE
    , c_attribute9              mtl_serial_numbers.c_attribute9%TYPE
    , c_attribute10             mtl_serial_numbers.c_attribute10%TYPE
    , c_attribute11             mtl_serial_numbers.c_attribute11%TYPE
    , c_attribute12             mtl_serial_numbers.c_attribute12%TYPE
    , c_attribute13             mtl_serial_numbers.c_attribute13%TYPE
    , c_attribute14             mtl_serial_numbers.c_attribute14%TYPE
    , c_attribute15             mtl_serial_numbers.c_attribute15%TYPE
    , c_attribute16             mtl_serial_numbers.c_attribute16%TYPE
    , c_attribute17             mtl_serial_numbers.c_attribute17%TYPE
    , c_attribute18             mtl_serial_numbers.c_attribute18%TYPE
    , c_attribute19             mtl_serial_numbers.c_attribute19%TYPE
    , c_attribute20             mtl_serial_numbers.c_attribute20%TYPE
    , d_attribute1              mtl_serial_numbers.d_attribute1%TYPE
    , d_attribute2              mtl_serial_numbers.d_attribute2%TYPE
    , d_attribute3              mtl_serial_numbers.d_attribute3%TYPE
    , d_attribute4              mtl_serial_numbers.d_attribute4%TYPE
    , d_attribute5              mtl_serial_numbers.d_attribute5%TYPE
    , d_attribute6              mtl_serial_numbers.d_attribute6%TYPE
    , d_attribute7              mtl_serial_numbers.d_attribute7%TYPE
    , d_attribute8              mtl_serial_numbers.d_attribute8%TYPE
    , d_attribute9              mtl_serial_numbers.d_attribute9%TYPE
    , d_attribute10             mtl_serial_numbers.d_attribute10%TYPE
    , n_attribute1              mtl_serial_numbers.n_attribute1%TYPE
    , n_attribute2              mtl_serial_numbers.n_attribute2%TYPE
    , n_attribute3              mtl_serial_numbers.n_attribute3%TYPE
    , n_attribute4              mtl_serial_numbers.n_attribute4%TYPE
    , n_attribute5              mtl_serial_numbers.n_attribute5%TYPE
    , n_attribute6              mtl_serial_numbers.n_attribute6%TYPE
    , n_attribute7              mtl_serial_numbers.n_attribute7%TYPE
    , n_attribute8              mtl_serial_numbers.n_attribute8%TYPE
    , n_attribute9              mtl_serial_numbers.n_attribute9%TYPE
    , n_attribute10             mtl_serial_numbers.n_attribute10%TYPE
    );


    -- Constants and types declaration

    TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    -- Task Record
    SUBTYPE task_rec IS wms_dispatched_tasks%ROWTYPE;

    -- ATF Related constants
    G_ATF_ACTIVATE_PLAN    CONSTANT NUMBER := 1;
    G_ATF_ABORT_PLAN       CONSTANT NUMBER := 2;
    G_ATF_CANCEL_PLAN      CONSTANT NUMBER := 3;

    G_OP_TYPE_DROP         CONSTANT NUMBER := wms_globals.G_OP_TYPE_DROP;
    G_OP_ACTIVITY_INBOUND  CONSTANT NUMBER := wms_globals.G_OP_ACTIVITY_INBOUND;

    /**Constants defined for Inspection Flag in validate_operation
    */
    G_NO_INSPECTION      CONSTANT NUMBER:=1;
    G_PARTIAL_INSPECTION CONSTANT NUMBER:=2;
    G_FULL_INSPECTION    CONSTANT NUMBER:=3;

    /**Constants defined for Load Flag in validate_operation
    */
    G_NO_LOAD      CONSTANT NUMBER:=1;
    G_PARTIAL_LOAD CONSTANT NUMBER:=2;
    G_FULL_LOAD    CONSTANT NUMBER:=3;


    /**Constants defined for Drop Flag in validate_operation
    */
    G_NO_DROP      CONSTANT NUMBER:=1;
    G_PARTIAL_DROP CONSTANT NUMBER:=2;
    G_FULL_DROP    CONSTANT NUMBER:=3;


  PROCEDURE mydebug(msg IN VARCHAR2) IS
    l_msg   VARCHAR2(5100);
    l_ts    VARCHAR2(30);
  BEGIN
    --   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
    --   l_msg:=l_ts||'  '||msg;

    l_msg := msg;
    inv_mobile_helper_functions.tracelog(p_err_msg => l_msg
        , p_module => 'WMS_Task_Dispatch_put_away'
        , p_level => 4);
    --dbms_output.put_line(l_msg);
    NULL;
  END;

  PROCEDURE create_mo_line(
    p_org_id                      IN             NUMBER
  , p_inventory_item_id           IN             NUMBER
  , p_qty                         IN             NUMBER
  , p_uom                         IN             VARCHAR2
  , p_lpn                         IN             NUMBER
  , p_project_id                  IN             NUMBER
  , p_task_id                     IN             NUMBER
  , p_reference                   IN             VARCHAR2
  , p_reference_type_code         IN             NUMBER
  , p_reference_id                IN             NUMBER
  , p_header_id                   IN             NUMBER
  , p_lot_number                  IN             VARCHAR2
  , p_revision                    IN             VARCHAR2
  , p_inspection_status           IN             NUMBER := NULL
  , p_txn_source_id               IN             NUMBER := fnd_api.g_miss_num
  , p_transaction_type_id         IN             NUMBER := fnd_api.g_miss_num
  , p_transaction_source_type_id  IN             NUMBER := fnd_api.g_miss_num
  , p_wms_process_flag            IN             NUMBER := NULL
  , x_return_status               OUT NOCOPY     VARCHAR2
  , x_msg_count                   OUT NOCOPY     NUMBER
  , x_msg_data                    OUT NOCOPY     VARCHAR2
  , p_from_cost_group_id          IN             NUMBER := NULL
  , p_sec_qty                     IN             NUMBER := NULL   -- Added for OPM convergance
  , p_sec_uom                     IN             VARCHAR2 := NULL -- Added for OPM convergance
  , x_line_id                    OUT nocopy NUMBER    -- Added for R12 MOL Consolidation
  ) IS
    l_trolin_tbl         inv_move_order_pub.trolin_tbl_type;
    l_return_status      VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2400);
    l_trohdr_val_rec     inv_move_order_pub.trolin_val_tbl_type;
    l_commit             VARCHAR2(1)                            := fnd_api.g_false;
    l_trolin_val_tbl     inv_move_order_pub.trolin_val_tbl_type;
    l_line_num           NUMBER      := 0;
    l_header_id          NUMBER      := fnd_api.g_miss_num;
    l_order_count        NUMBER      := 1;
    l_trohdr_val_rec     inv_move_order_pub.trohdr_val_rec_type;
    l_commit             VARCHAR2(1) := fnd_api.g_false;
    p_need_by_date       DATE        := SYSDATE;
    p_src_subinv         VARCHAR2(30);
    l_org_id             NUMBER;
    l_inventory_item_id  NUMBER;
    l_lpn                NUMBER;
    l_qty                NUMBER;
    l_uom                VARCHAR2(60);
    l_project_id         NUMBER;
    l_task_id            NUMBER;
    l_ref                VARCHAR2(240);
    l_ref_type           NUMBER;
    l_ref_id             NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number         VARCHAR2(80);
    l_revision           VARCHAR2(3);
    l_txn_type_id        NUMBER      := fnd_api.g_miss_num;
    l_txn_source_id      NUMBER      := fnd_api.g_miss_num;
    l_txn_source_type_id NUMBER      := fnd_api.g_miss_num;
    l_insp_status        NUMBER;
    l_wms_process_flag   NUMBER;
    l_cg_id              NUMBER;
    l_tcg_id             NUMBER;
    l_cg_line            NUMBER;
    l_from_cg_id         NUMBER;
    l1                   VARCHAR2(30);
    l2                   NUMBER;
    l3                   NUMBER;
    l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_sec_qty            NUMBER; -- Added for OPM convergance
    l_sec_uom            VARCHAR2(3); -- Added for OPM convergance
  BEGIN
    --Get Max line number
    SELECT MAX(line_number)
    INTO   l_line_num
    FROM   mtl_txn_request_lines
    WHERE  header_id = p_header_id;

    l_header_id := p_header_id;
    l_org_id := p_org_id;
    l_inventory_item_id := p_inventory_item_id;
    l_lpn := p_lpn;
    l_qty := p_qty;
    l_uom := p_uom;
    l_project_id := p_project_id;
    /*
    ** Bug 2677818
    ** l_task_id:=l_task_id;
    ** Correcting this as below
    */
    l_task_id := p_task_id;
    l_ref := p_reference;
    l_ref_type := p_reference_type_code;
    l_ref_id := p_reference_id;
    l_lot_number := p_lot_number;
    l_revision := p_revision;
    l_insp_status := p_inspection_status;
    l_wms_process_flag := p_wms_process_flag;
    l_from_cg_id := p_from_cost_group_id;

    l_sec_qty := p_sec_qty; -- Added for OPM convergance
    l_sec_uom := p_sec_uom; -- Added for OPM convergance

    -- Derive txn_source and type info

    /*Bug 5662957:set the txn_type_id = 12 and txn_source_type_id =13 if reference_type_code = 6.
    The same was already done in create_mo() API as a part of bug fix 4996680.*/

    IF (l_ref_type = 4) THEN
      l_txn_type_id := 18;
      l_txn_source_type_id := 1;
    ELSIF(l_ref_type = 8) THEN
      l_txn_type_id := 61;
      l_txn_source_type_id := 7;
    ELSIF(l_ref_type = 7) THEN
      l_txn_type_id := 15;
      l_txn_source_type_id := 12;
    ELSIF(l_ref_type = 6) THEN
      l_txn_type_id         := 12;
      l_txn_source_type_id  := 13;
    ELSE
      l_txn_type_id := 18;
      l_txn_source_type_id := 1;
    END IF;

    -- Note might need to add additional stuff here
    -- Added for WIP
    IF (p_txn_source_id <> fnd_api.g_miss_num) THEN
      l_txn_source_id := p_txn_source_id;
    ELSE
      l_txn_source_id := NULL;
    END IF;

    IF (p_transaction_source_type_id <> fnd_api.g_miss_num) THEN
      l_txn_source_type_id := p_transaction_source_type_id;
    END IF;

    IF (p_transaction_type_id <> fnd_api.g_miss_num) THEN
      l_txn_type_id := p_transaction_type_id;
    END IF;

    --Increment by 1
    l_line_num := l_line_num + 1;
    l_trolin_tbl(l_order_count).header_id := p_header_id;
    l_trolin_tbl(l_order_count).created_by := fnd_global.user_id;
    l_trolin_tbl(l_order_count).creation_date := SYSDATE;
    l_trolin_tbl(l_order_count).date_required           := SYSDATE;
    l_trolin_tbl(l_order_count).from_subinventory_code  := NULL;
    l_trolin_tbl(l_order_count).inventory_item_id       := p_inventory_item_id;
    l_trolin_tbl(l_order_count).last_updated_by         := fnd_global.user_id;
    l_trolin_tbl(l_order_count).last_update_date        := SYSDATE;
    l_trolin_tbl(l_order_count).last_update_login       := fnd_global.login_id;
    l_trolin_tbl(l_order_count).line_id                 := fnd_api.g_miss_num;
    l_trolin_tbl(l_order_count).line_number             := l_line_num;
    l_trolin_tbl(l_order_count).line_status             := inv_globals.g_to_status_preapproved;
    l_trolin_tbl(l_order_count).organization_id         := p_org_id;
    l_trolin_tbl(l_order_count).quantity                := p_qty;
    l_trolin_tbl(l_order_count).status_date             := SYSDATE;
    l_trolin_tbl(l_order_count).to_subinventory_code    := NULL;
    l_trolin_tbl(l_order_count).uom_code                := p_uom;
    l_trolin_tbl(l_order_count).db_flag                 := fnd_api.g_true;
    l_trolin_tbl(l_order_count).operation               := inv_globals.g_opr_create;
    l_trolin_tbl(l_order_count).lpn_id                  := p_lpn;
    l_trolin_tbl(l_order_count).REFERENCE               := l_ref;
    l_trolin_tbl(l_order_count).reference_type_code     := l_ref_type;
    l_trolin_tbl(l_order_count).reference_id            := l_ref_id;
    l_trolin_tbl(l_order_count).project_id              := l_project_id;
    l_trolin_tbl(l_order_count).task_id                 := l_task_id;
    l_trolin_tbl(l_order_count).lot_number              := l_lot_number;
    l_trolin_tbl(l_order_count).revision                := l_revision;
    l_trolin_tbl(l_order_count).transaction_type_id     := l_txn_type_id;
    l_trolin_tbl(l_order_count).transaction_source_type_id := l_txn_source_type_id;
    l_trolin_tbl(l_order_count).inspection_status       := l_insp_status;
    l_trolin_tbl(l_order_count).wms_process_flag        := l_wms_process_flag;
    l_trolin_tbl(l_order_count).secondary_quantity      := l_sec_qty; -- Added for OPM convergance
    l_trolin_tbl(l_order_count).secondary_uom           := l_sec_uom; -- Added for OPM convergance

    IF (p_txn_source_id <> fnd_api.g_miss_num) THEN
      l_trolin_tbl(l_order_count).txn_source_id := l_txn_source_id;
    END IF;

    l_trolin_tbl(l_order_count).from_cost_group_id  := l_from_cg_id;
    l_trolin_tbl(l_order_count).to_cost_group_id    := l_from_cg_id;

    inv_move_order_pub.create_move_order_lines(
      p_api_version_number     => 1.0
    , p_init_msg_list          => 'F'
    , p_commit                 => fnd_api.g_false
    , x_return_status          => l_return_status
    , x_msg_count              => l_msg_count
    , x_msg_data               => l_msg_data
    , p_trolin_tbl             => l_trolin_tbl
    , p_trolin_val_tbl         => l_trolin_val_tbl
    , x_trolin_tbl             => l_trolin_tbl
    , x_trolin_val_tbl         => l_trolin_val_tbl
    );

    IF (l_debug = 1) THEN
      mydebug('create_mo_line: Org');
      mydebug('create_mo_line: ' || l_trolin_tbl(1).organization_id);
      mydebug('create_mo_line: Line');
      mydebug('create_mo_line: ' || l_trolin_tbl(1).line_id);
      mydebug('create_mo_line: Status ');
      mydebug('create_mo_line: ' || l_return_status);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      fnd_message.set_name('WMS', 'WMS_TD_MOL_ERROR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
      fnd_message.set_name('WMS', 'WMS_TD_MOL_ERROR');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_cg_line := l_trolin_tbl(1).line_id;
    x_line_id := l_trolin_tbl(1).line_id;

    IF (l_debug = 1) THEN
      mydebug('create_mo_line: Line: ' || l_cg_line);
    END IF;

    SELECT from_subinventory_code
         , from_cost_group_id
         , to_cost_group_id
    INTO   l1
         , l2
         , l3
    FROM   mtl_txn_request_lines
    WHERE  line_id = l_cg_line;

    IF (l_debug = 1) THEN
      mydebug('create_mo_line: Act Sub: ' || l1);
      mydebug('create_mo_line: Act FCG: ' || l2);
      mydebug('create_mo_line: Act TCG: ' || l3);
    END IF;

    IF l_from_cg_id IS NULL THEN
      IF (l_debug = 1) THEN
        mydebug('create_mo_line: Calling CG Engine');
      END IF;

      -- Call Cost Group Engine
      inv_cost_group_pub.assign_cost_group(
        p_api_version_number         => 1.0
      , p_init_msg_list              => fnd_api.g_false
      , p_commit                     => fnd_api.g_false
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_line_id                    => l_cg_line
      , p_organization_id            => l_org_id
      , p_input_type                 => inv_cost_group_pub.g_input_moline
      , x_cost_group_id              => l_cg_id
      , x_transfer_cost_group_id     => l_tcg_id
      );

      IF (l_debug = 1) THEN
        mydebug('create_mo_line: After Calling CG Engine');
        mydebug('create_mo_line: CG: ' || l_cg_id);
        mydebug('create_mo_line: TCG: ' || l_tcg_id);
      END IF;

      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);

      IF (l_msg_count = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('create_mo_line: Successful');
        END IF;
      ELSIF(l_msg_count = 1) THEN
        IF (l_debug = 1) THEN
          mydebug('create_mo_line: Not Successful');
          mydebug(REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('create_mo_line: Not Successful2');
        END IF;

        FOR i IN 1 .. l_msg_count LOOP
          l_msg_data := fnd_msg_pub.get(i, 'F');

          IF (l_debug = 1) THEN
            mydebug('create_mo_line: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        END LOOP;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CG_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CG_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_mo_line;

  PROCEDURE create_mo(
    p_org_id                      IN             NUMBER
  , p_inventory_item_id           IN             NUMBER
  , p_qty                         IN             NUMBER
  , p_uom                         IN             VARCHAR2
  , p_lpn                         IN             NUMBER
  , p_project_id                  IN             NUMBER := NULL
  , p_task_id                     IN             NUMBER := NULL
  , p_reference                   IN             VARCHAR2 := NULL
  , p_reference_type_code         IN             NUMBER := NULL
  , p_reference_id                IN             NUMBER := NULL
  , p_lot_number                  IN             VARCHAR2
  , p_revision                    IN             VARCHAR2
  , p_header_id                   IN OUT NOCOPY  NUMBER
  , p_sub                         IN             VARCHAR := NULL
  , p_loc                         IN             NUMBER  := NULL
  , x_line_id                     OUT NOCOPY     NUMBER
  , p_inspection_status           IN             NUMBER  := NULL
  , p_txn_source_id               IN             NUMBER  := fnd_api.g_miss_num
  , p_transaction_type_id         IN             NUMBER  := fnd_api.g_miss_num
  , p_transaction_source_type_id  IN             NUMBER  := fnd_api.g_miss_num
  , p_wms_process_flag            IN             NUMBER  := NULL
  , x_return_status               OUT NOCOPY     VARCHAR2
  , x_msg_count                   OUT NOCOPY     NUMBER
  , x_msg_data                    OUT NOCOPY     VARCHAR2
  , p_from_cost_group_id          IN             NUMBER  := NULL
  , p_transfer_org_id             IN             NUMBER  DEFAULT NULL
  , p_sec_qty                     IN             NUMBER := NULL -- Added for OPM Convergance
  , p_sec_uom                     IN             VARCHAR2 := NULL -- Added for OPM Convergance
  ) IS
    l_trohdr_rec         inv_move_order_pub.trohdr_rec_type;
    l_trolin_tbl         inv_move_order_pub.trolin_tbl_type;
    l_trolin_val_tbl     inv_move_order_pub.trolin_val_tbl_type;
    l_return_status      VARCHAR2(1)   := fnd_api.g_ret_sts_success;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    msg                  VARCHAR2(2000);
    l_header_id          NUMBER        := fnd_api.g_miss_num;
    l_line_num           NUMBER        := 0;
    l_order_count        NUMBER        := 1;
    l_trohdr_val_rec     inv_move_order_pub.trohdr_val_rec_type;
    l_commit             VARCHAR2(1)   := fnd_api.g_false;
    p_need_by_date       DATE          := SYSDATE;
    p_src_subinv         VARCHAR2(30);
    l_org_id             NUMBER;
    l_inventory_item_id  NUMBER;
    l_lpn                NUMBER;
    l_qty                NUMBER;
    l_uom                VARCHAR2(60);
    l_project_id         NUMBER;
    l_task_id            NUMBER;
    l_ref                VARCHAR2(240);
    l_ref_type           NUMBER;
    l_ref_id             NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number         VARCHAR2(80);
    l_revision           VARCHAR2(3);
    l_txn_type_id        NUMBER        := fnd_api.g_miss_num;
    l_txn_source_id      NUMBER        := fnd_api.g_miss_num;
    l_txn_source_type_id NUMBER        := fnd_api.g_miss_num;
    l_insp_status        NUMBER;
    l_wms_process_flag   NUMBER;
    l_cg_id              NUMBER;
    l_tcg_id             NUMBER;
    l_cg_line            NUMBER;
    l_from_cg_id         NUMBER;
    l1                   VARCHAR2(30);
    l2                   NUMBER;
    l3                   NUMBER;
    l_project_comingle   NUMBER;
    l_debug              NUMBER        := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_sec_qty            NUMBER;
    l_sec_uom            VARCHAR2(3);
    l_lpn_id_chk         number;


	l_lot_code           NUMBER;  --bug#10415632
    l_serial_control_code NUMBER;--13390994
    l_serial_count       NUMBER; --13390994
    l_lpn_context        NUMBER; --13695803
    l_inspection_status_code VARCHAR2(50); --13722443
  BEGIN
    l_header_id := p_header_id;

    IF p_header_id = 0 THEN
      l_header_id := fnd_api.g_miss_num;
    END IF;

    l_org_id            := p_org_id;
    l_inventory_item_id := p_inventory_item_id;
    l_lpn               := p_lpn;
    l_qty               := p_qty;
    l_uom               := p_uom;
    l_project_id        := p_project_id;
    /*
    ** l_task_id:=l_task_id;
    ** Correcting this as below
    */
    l_task_id           := p_task_id;
    l_ref               := p_reference;
    l_ref_type          := p_reference_type_code;
    l_ref_id            := p_reference_id;
    l_lot_number        := p_lot_number;
    l_revision          := p_revision;
    l_insp_status       := p_inspection_status;
    l_wms_process_flag  := p_wms_process_flag;
    l_from_cg_id        := p_from_cost_group_id;
    l_return_status     := fnd_api.g_ret_sts_success;

    l_sec_qty           := p_sec_qty; -- Added for OPM convergance
    l_sec_uom           := p_sec_uom; -- Added for OPM convergance

    /* If we are trying to create an MTRL with out LPN, check if there is RS
       which does not have lpn_id stamped. If it does not exists throw an exception
       and stop creation of MTRL
    */

   -- 13588879
    if p_reference in ('PO_LINE_LOCATION_ID','SHIPMENT_LINE_ID','ORDER_LINE_ID') then

	    mydebug('p_lpn =  '||p_lpn);
	    mydebug('p_txn_source_id =  '||p_txn_source_id);
	    if p_lpn is null then
	       if (p_txn_source_id <> fnd_api.g_miss_num) then
			 begin
			  select lpn_id into l_lpn_id_chk
			  from rcv_supply rs
			  where rs.rcv_transaction_id = p_txn_source_id
			  and rs.lpn_id is null;
			 exception
			  when others then
				mydebug('In exception -- select fails' ) ;
				fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
				fnd_msg_pub.ADD;
				RAISE fnd_api.g_exc_error;
			 end;
	       end if;
	    end if;

    end if;
	-- 13588879
    /*
    ** Sense project/task comingling in LPN
    */
    IF ((p_lpn > 0) AND(p_org_id > 0)) THEN
      BEGIN
        SELECT 1
        INTO   l_project_comingle
        FROM   DUAL
        WHERE  EXISTS(
                 SELECT 1
                 FROM   mtl_txn_request_lines
                 WHERE  lpn_id = p_lpn
                 AND    organization_id = p_org_id
                 AND    line_status <> inv_globals.g_to_status_closed
                 AND    NVL(project_id, -1) <> NVL(p_project_id, -1)
                 AND    NVL(task_id, -1) <> NVL(p_task_id, -1));

        fnd_message.set_name('WMS', 'WMS_PROJ_LPN_COMINGLE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      /*
      ** To identify lot corruption in WMS enabled orgs   --bug#10415632
      */
	  --13390994
	  --Removed the query to fetch Lot Control and got it from Cache
     IF inv_cache.set_item_rec(p_org_id , l_inventory_item_id) THEN
        l_lot_code := inv_cache.item_rec.lot_control_code;
        l_serial_control_code := inv_cache.item_rec.serial_number_control_code;
     END IF;
     IF (l_debug = 1) THEN
      mydebug('create_mo: Item Id : ' || l_inventory_item_id || ', Lot Control code : ' || l_lot_code||', Lot Number : '|| l_lot_number);
      mydebug('create_mo: Item Id : ' || l_inventory_item_id || ', Serial Control Code : ' || l_serial_control_code);
     END IF;

      IF (l_lot_code = 2 AND l_lot_number IS NULL) THEN
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_serial_control_code NOT IN (1,6) THEN
	   --13695803
       SELECT lpn_context
         INTO l_lpn_context
         FROM wms_license_plate_numbers
        WHERE lpn_id = l_lpn
		  AND organization_id = l_org_id;

       IF l_lpn_context = 3 THEN
		-- Modified the query below to take care of -ve Correction Transaction
		-- and issue with Multiple Lots, Revision for the same item in the same LPN
		-- 13722443
		IF Nvl(p_inspection_status,1) = 1 THEN
           l_inspection_status_code := 'NOT INSPECTED';
        ELSIF
           p_inspection_status = 2 THEN
           l_inspection_status_code := 'ACCEPTED';
        ELSIF
           p_inspection_status = 3 THEN
           l_inspection_status_code := 'REJECTED';
        END IF;
		--13722443
       SELECT COUNT(distinct(rss.serial_num))
         INTO l_serial_count
         FROM rcv_serials_supply rss, rcv_supply rs , rcv_transactions rt , rcv_lots_supply rls
        WHERE rs.rcv_transaction_id = rss.transaction_id
          AND rs.rcv_transaction_id = rt.transaction_id
          AND rt.inspection_status_code = l_inspection_status_code
          AND rs.shipment_line_id = rss.shipment_line_id
	      AND p_reference_id = DECODE(l_ref_type,4, Decode(l_ref, 'PO_LINE_LOCATION_ID' , rt.po_line_location_id,
	                                                              'SHIPMENT_LINE_ID' , rt.shipment_line_id),
                                                 6, rt.shipment_line_id,
                                                 7, rt.oe_order_line_id,
                                                 8, rt.shipment_line_id) --14133874
          AND Nvl(rs.item_revision,'@@@') = Nvl(p_revision,'@@@')
          AND rs.rcv_transaction_id = rls.transaction_id(+)
          AND Nvl(rls.lot_num,'@@@') = Nvl(p_lot_number,'@@@')
          AND rss.supply_type_code = 'RECEIVING'
          AND Nvl(rss.lot_num , '@#@')= Nvl(rls.lot_num,'@#@')
          AND rs.lpn_id = l_lpn
          AND rs.item_id = l_inventory_item_id
          AND rs.to_organization_id = l_org_id
          AND EXISTS(SELECT 1
                       FROM mtl_serial_numbers msn
                      WHERE msn.inventory_item_id = l_inventory_item_id
                      --  AND msn.lpn_id = rs.lpn_id --14133874
                        AND msn.serial_number = rss.serial_num );

       IF (l_debug = 1) THEN
        mydebug('create_mo: Serial Count in RSS : ' || l_serial_count || ', p_qty : ' || p_qty);
       END IF;

        IF (l_serial_count <> p_qty) THEN
          mydebug('Discrepancy in Serial qty and qty recd');
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

      END IF; --13695803
      END IF;
	  --13390994

	END IF;

    -- Derive txn_source and type info
    IF (l_ref_type = 4)   THEN
      l_txn_type_id         := 18;
      l_txn_source_type_id  := 1;
    ELSIF(l_ref_type = 8) THEN
      l_txn_type_id         := 61;
      l_txn_source_type_id  := 7;
    ELSIF(l_ref_type = 7) THEN
      l_txn_type_id         := 15;
      l_txn_source_type_id  := 12;
    ELSIF(l_ref_type = 6) THEN
         l_txn_type_id         := 12;
         l_txn_source_type_id  := 13;
    ELSE
      l_txn_type_id         := 18;
      l_txn_source_type_id  := 1;
    END IF;

    -- Note might need to add additional stuff here
    -- Added for WIP
    IF (p_txn_source_id <> fnd_api.g_miss_num) THEN
      l_txn_source_id := p_txn_source_id;
    ELSE
      l_txn_source_id := NULL;
    END IF;

    IF (p_transaction_source_type_id <> fnd_api.g_miss_num) THEN
      l_txn_source_type_id := p_transaction_source_type_id;
    END IF;

    IF (p_transaction_type_id <> fnd_api.g_miss_num) THEN
      l_txn_type_id := p_transaction_type_id;
    END IF;

    l_trohdr_rec.created_by                                 := fnd_global.user_id;
    l_trohdr_rec.creation_date                              := SYSDATE;
    l_trohdr_rec.date_required                              := SYSDATE;
    l_trohdr_rec.from_subinventory_code                     := p_sub;
    l_trohdr_rec.header_status                              := inv_globals.g_to_status_preapproved;
    l_trohdr_rec.last_updated_by                            := fnd_global.user_id;
    l_trohdr_rec.last_update_date                           := SYSDATE;
    l_trohdr_rec.last_update_login                          := fnd_global.user_id;
    l_trohdr_rec.organization_id                            := l_org_id;
    l_trohdr_rec.status_date                                := SYSDATE;
    l_trohdr_rec.to_subinventory_code                       := NULL;
    l_trohdr_rec.move_order_type                            := inv_globals.g_move_order_put_away;
    l_trohdr_rec.db_flag                                    := fnd_api.g_true;
    l_trohdr_rec.operation                                  := inv_globals.g_opr_create;
    l_line_num                                              := l_line_num + 1;
    l_trolin_tbl(l_order_count).header_id                   := l_trohdr_rec.header_id;
    l_trolin_tbl(l_order_count).created_by                  := fnd_global.user_id;
    l_trolin_tbl(l_order_count).creation_date               := SYSDATE;
    l_trolin_tbl(l_order_count).date_required               := SYSDATE;
    l_trolin_tbl(l_order_count).from_subinventory_code      := p_sub;
    l_trolin_tbl(l_order_count).from_locator_id             := p_loc;
    l_trolin_tbl(l_order_count).inventory_item_id           := l_inventory_item_id;
    l_trolin_tbl(l_order_count).last_updated_by             := fnd_global.user_id;
    l_trolin_tbl(l_order_count).last_update_date            := SYSDATE;
    l_trolin_tbl(l_order_count).last_updated_by             := fnd_global.user_id;
    l_trolin_tbl(l_order_count).last_update_date            := SYSDATE;
    l_trolin_tbl(l_order_count).last_update_login           := fnd_global.login_id;
    l_trolin_tbl(l_order_count).line_id                     := fnd_api.g_miss_num;
    l_trolin_tbl(l_order_count).line_number                 := l_line_num;
    l_trolin_tbl(l_order_count).line_status                 := inv_globals.g_to_status_preapproved;
    l_trolin_tbl(l_order_count).organization_id             := l_org_id;
    l_trolin_tbl(l_order_count).quantity                    := l_qty;
    l_trolin_tbl(l_order_count).status_date                 := SYSDATE;
    l_trolin_tbl(l_order_count).to_subinventory_code        := NULL;
    l_trolin_tbl(l_order_count).uom_code                    := l_uom;
    l_trolin_tbl(l_order_count).db_flag                     := fnd_api.g_true;
    l_trolin_tbl(l_order_count).operation                   := inv_globals.g_opr_create;
    l_trolin_tbl(l_order_count).lpn_id                      := p_lpn;
    l_trolin_tbl(l_order_count).REFERENCE                   := l_ref;
    l_trolin_tbl(l_order_count).reference_type_code         := l_ref_type;
    l_trolin_tbl(l_order_count).reference_id                := l_ref_id;
    l_trolin_tbl(l_order_count).project_id                  := l_project_id;
    l_trolin_tbl(l_order_count).task_id                     := l_task_id;
    l_trolin_tbl(l_order_count).lot_number                  := l_lot_number;
    l_trolin_tbl(l_order_count).revision                    := l_revision;
    l_trolin_tbl(l_order_count).transaction_type_id         := l_txn_type_id;
    l_trolin_tbl(l_order_count).transaction_source_type_id  := l_txn_source_type_id;
    l_trolin_tbl(l_order_count).inspection_status           := l_insp_status;
    l_trolin_tbl(l_order_count).wms_process_flag            := l_wms_process_flag;
    -- Added this to be populated for intransit shipments.
    l_trolin_tbl(l_order_count).to_organization_id          := p_transfer_org_id;

    l_trolin_tbl(l_order_count).secondary_quantity          := l_sec_qty; -- Added for OPM convergance
    l_trolin_tbl(l_order_count).secondary_uom               := l_sec_uom; -- Added for OPM convergance

    --  l_trolin_tbl(l_order_count).move_order_type:=inv_globals.g_move_order_put_away;
    IF (p_txn_source_id <> fnd_api.g_miss_num) THEN
      l_trolin_tbl(l_order_count).txn_source_id := l_txn_source_id;
    END IF;

    l_trolin_tbl(l_order_count).from_cost_group_id := l_from_cg_id;
    l_trolin_tbl(l_order_count).to_cost_group_id := l_from_cg_id;

    IF (l_debug = 1) THEN
      mydebug('create_mo: Before Checking header');
    END IF;

    IF (l_header_id IS NULL
        OR l_header_id = fnd_api.g_miss_num) THEN
      IF (l_debug = 1) THEN
        mydebug('create_mo: Header Not passed. Calling Process_Move_Order');
      END IF;

      inv_move_order_pub.process_move_order(
        p_api_version_number     => 1.0
      , p_init_msg_list          => 'F'
      , p_commit                 => fnd_api.g_false
      , x_return_status          => l_return_status
      , x_msg_count              => l_msg_count
      , x_msg_data               => l_msg_data
      , p_trohdr_rec             => l_trohdr_rec
      , p_trohdr_val_rec         => l_trohdr_val_rec
      , p_trolin_tbl             => l_trolin_tbl
      , p_trolin_val_tbl         => l_trolin_val_tbl
      , x_trohdr_rec             => l_trohdr_rec
      , x_trohdr_val_rec         => l_trohdr_val_rec
      , x_trolin_tbl             => l_trolin_tbl
      , x_trolin_val_tbl         => l_trolin_val_tbl
      );
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);

      IF (l_msg_count = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('create_mo: Successful');
        END IF;
      ELSIF(l_msg_count = 1) THEN
        IF (l_debug = 1) THEN
          mydebug('create_mo: Not Successful');
          mydebug('create_mo: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('create_mo: Not Successful2');
        END IF;

        FOR i IN 1 .. l_msg_count LOOP
          l_msg_data := fnd_msg_pub.get(i, 'F');

          IF (l_debug = 1) THEN
            mydebug('create_mo: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        END LOOP;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_MO_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_MO_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Get header and line ids */
      p_header_id := l_trohdr_rec.header_id;
      x_line_id := l_trolin_tbl(l_order_count).line_id;

      IF (l_debug = 1) THEN
        mydebug('create_mo: Header' || p_header_id);
        mydebug('create_mo: Org');
        mydebug('create_mo: ' || l_trolin_tbl(1).organization_id);
      END IF;

      l_cg_line := l_trolin_tbl(1).line_id;

      IF (l_debug = 1) THEN
        mydebug('create_mo: Line: ' || l_cg_line);
        mydebug('create_mo: From CG ' || l_trolin_tbl(1).from_cost_group_id);
        mydebug('create_mo: To CG ' || l_trolin_tbl(1).to_cost_group_id);
        mydebug('create_mo: From Sub ' || l_trolin_tbl(1).from_subinventory_code);
      END IF;

      SELECT from_subinventory_code
           , from_cost_group_id
           , to_cost_group_id
      INTO   l1
           , l2
           , l3
      FROM   mtl_txn_request_lines
      WHERE  line_id = l_cg_line;

      IF (l_debug = 1) THEN
        mydebug('create_mo: Act Sub: ' || l1);
        mydebug('create_mo: Act FCG: ' || l2);
        mydebug('create_mo: Act TCG: ' || l3);
      END IF;

      IF l_from_cg_id IS NULL THEN
        IF (l_debug = 1) THEN
          mydebug('create_mo: Calling CG Engine');
        END IF;

        inv_cost_group_pub.assign_cost_group(
          p_api_version_number         => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_commit                     => fnd_api.g_false
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_line_id                    => l_cg_line
        , p_organization_id            => l_org_id
        , p_input_type                 => inv_cost_group_pub.g_input_moline
        , x_cost_group_id              => l_cg_id
        , x_transfer_cost_group_id     => l_tcg_id
        );

        IF (l_debug = 1) THEN
          mydebug('create_mo: After Calling CG Engine');
          mydebug('create_mo: CG: ' || l_cg_id);
          mydebug('create_mo: TCG: ' || l_tcg_id);
        END IF;

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            mydebug('create_mo: UnexpError In CG');
          END IF;

          fnd_message.set_name('WMS', 'WMS_TD_CG_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            mydebug('create_mo: Error In CG');
          END IF;

          fnd_message.set_name('WMS', 'WMS_TD_CG_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('create_mo: Header was passed. Calling create_mo_line');
      END IF;

      wms_task_dispatch_put_away.create_mo_line(
        p_org_id                         => l_org_id
      , p_inventory_item_id              => l_inventory_item_id
      , p_qty                            => l_qty
      , p_uom                            => l_uom
      , p_lpn                            => l_lpn
      , p_project_id                     => l_project_id
      , p_task_id                        => l_task_id
      , p_reference                      => l_ref
      , p_reference_type_code            => l_ref_type
      , p_reference_id                   => l_ref_id
      , p_header_id                      => l_header_id
      , p_lot_number                     => l_lot_number
      , p_revision                       => l_revision
      , p_inspection_status              => l_insp_status
      , p_txn_source_id                  => l_txn_source_id
      , p_transaction_type_id            => l_txn_type_id
      , p_transaction_source_type_id     => l_txn_source_type_id
      , p_wms_process_flag               => l_wms_process_flag
      , x_return_status                  => l_return_status
      , x_msg_count                      => l_msg_count
      , x_msg_data                       => l_msg_data
      , p_from_cost_group_id             => l_from_cg_id
      , p_sec_qty                        => l_sec_qty
      , p_sec_uom                        => l_sec_uom
      , x_line_id                        => x_line_id
	);

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_MO_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_MO_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF SQLCODE IS NOT NULL THEN
        inv_mobile_helper_functions.sql_error('WMS_Task_Dispatch_put_away.create_mo', '10', SQLCODE);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_mo;

  -- added for bug 3401817
  -- An autonomous_transaction wrapper arount wms_putaway_suggestions.cleanup_suggestions
  -- This is because after cleanup_suggestions, we call create_suggestions,
  -- which may very well suggest the same locator. In cleanup_suggestions, we call abort_operation_instance, which
  -- in turn calls revert_loc_sugg_capacity_nauto. However, in create_suggestions, we call update_loc_suggested_capacity,
  -- with autonomous_transaction, which will cause resource busy.

  /*
PROCEDURE cleanup_suggestions
( p_org_id              IN          NUMBER
, p_lpn_id              IN          NUMBER
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
, p_move_order_line_id  IN          NUMBER   DEFAULT NULL  -- added for ATF_J2
) IS
  PRAGMA autonomous_transaction;
BEGIN
  wms_putaway_suggestions.cleanup_suggestions
  ( p_lpn_id              => p_lpn_id
  , p_org_id              => p_org_id
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  , p_move_order_line_id  => p_move_order_line_id
  );
  COMMIT;
END;

  */

  -- Create Putaway Suggestions
  -- Bug# 2752119
  -- Added an extra input parameter called p_check_for_crossdock
  -- which will default to 'Y' = Yes.
  -- This is needed when we are performing an Express Drop and need
  -- to validate against the rules.  In that case, it is possible that
  -- a crossdocking opportunity exists but the user chose to ignore it
  -- and proceed with the express drop.  We should not call the
  -- crossdocking API's at all in that case since it might split the
  -- move order lines.
  PROCEDURE suggestions_pub(
    p_lpn_id               IN             NUMBER
  , p_org_id               IN             NUMBER
  , p_user_id              IN             NUMBER
  , p_eqp_ins              IN             VARCHAR2
  , x_number_of_rows       OUT NOCOPY     NUMBER
  , x_return_status        OUT NOCOPY     VARCHAR2
  , x_msg_count            OUT NOCOPY     NUMBER
  , x_msg_data             OUT NOCOPY     VARCHAR2
  , x_crossdock            OUT NOCOPY     VARCHAR2
  , p_status               IN             NUMBER := 3
  , p_check_for_crossdock  IN             VARCHAR2 := 'Y'
  , p_move_order_line_id   IN             NUMBER DEFAULT NULL -- added for ATF_J
  , p_commit               IN             VARCHAR2
  , p_drop_type            IN             VARCHAR2
  , p_subinventory         IN             VARCHAR2
  , p_locator_id           IN             NUMBER
  ) IS
    l_api_version_number  CONSTANT NUMBER        := 1.0;
    l_init_msg_list                VARCHAR2(255) := fnd_api.g_false;
    l_api_name            CONSTANT VARCHAR2(30)  := 'Suggestions_PUB';
    l_num_of_rows                  NUMBER        := 0;
    l_detailed_qty                 NUMBER        := 0;
    l_ser_index                    NUMBER;
    x_success                      NUMBER;
    l_revision                     VARCHAR2(3);
    l_transfer_to_location         NUMBER;
    l_locator_id                   NUMBER;
    l_transaction_temp_id          NUMBER;
    l_transaction_header_id        NUMBER;
    l_subinventory_code            VARCHAR2(30);
    l_transaction_quantity         NUMBER;
    l_inventory_item_id            NUMBER;
    l_temp_id                      NUMBER;
    l_mtl_reservation              inv_reservation_global.mtl_reservation_tbl_type;
    l_return_status                VARCHAR2(1);
    l_grouping_rule_id             NUMBER;
    l_message                      VARCHAR2(2000);
    l_msg_data                     VARCHAR2(2000);
    l_count                        NUMBER;
    l_msg_count                    NUMBER;
    l_from_serial_number           VARCHAR2(30);
    l_to_serial_number             VARCHAR2(30);
    l_priority                     NUMBER;
    l_std_op_id                    NUMBER;
    l_next_task_id                 NUMBER;
    l_wms_task_type                NUMBER;
    l_operation_plan_id            NUMBER;
    l_move_order_line_id           NUMBER;
    l_line_id                      NUMBER;
    l_serial_flag                  VARCHAR2(30)  := 'N';
    l_rcount                       NUMBER;
    l_lpn_id                       NUMBER;
    --     l_lpn_cont                      NUMBER;
    l_lpn_cg_id                    NUMBER;
    l_completion_txn_id            NUMBER;
    l_ref_id                       NUMBER;
    l_txn_source_type_id           NUMBER;
    l_flow_schedule                VARCHAR2(1);
    l_transaction_source_id        NUMBER;
    l_rows_detailed                NUMBER;
    l_mtl_status                   NUMBER;
    l_quantity_detailed            NUMBER;
    l_quantity                     NUMBER;
    l_backorder_delivery_detail_id NUMBER;
    l_crossdock_type               NUMBER;
    wdt_exist                      VARCHAR2(1)   := NULL;
    l_tt_id                        NUMBER        := NULL;

    CURSOR molines_csr IS
       SELECT mtrl.line_id
            , mtrl.reference_id
            , mtrl.transaction_source_type_id
            , mtrl.quantity_detailed
            , mtrl.quantity
            , mtrl.backorder_delivery_detail_id
	    , NVL(crossdock_type, 1)
	    , mtrl.to_subinventory_code
	    , mtrl.to_locator_id
            , mtrl.reference_detail_id
	 FROM   mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
	 WHERE  mtrl.lpn_id = p_lpn_id
	 AND    mtrl.organization_id = p_org_id
	 AND    mtrl.header_id = mtrh.header_id
	 AND    mtrl.line_status <> inv_globals.g_to_status_closed
	 AND    mtrh.move_order_type = inv_globals.g_move_order_put_away
	 AND    mtrl.line_id = NVL(p_move_order_line_id, mtrl.line_id)    -- added for ATF_J

     --BUG 5194761
     UNION
       SELECT mtrl.line_id
            , mtrl.reference_id
            , mtrl.transaction_source_type_id
            , mtrl.quantity_detailed
            , mtrl.quantity
            , mtrl.backorder_delivery_detail_id
	    , NVL(crossdock_type, 1)
	    , mtrl.to_subinventory_code
	    , mtrl.to_locator_id
            , mtrl.reference_detail_id
	 FROM   mtl_txn_request_lines mtrl, mtl_txn_request_headers mtrh
	 WHERE  mtrl.lpn_id = p_lpn_id
	 AND    mtrl.organization_id = p_org_id
	 AND    mtrl.header_id = mtrh.header_id
	 AND    mtrl.line_status <> inv_globals.g_to_status_closed
	 AND    mtrh.move_order_type = inv_globals.g_move_order_put_away
	 AND    p_move_order_line_id IS NOT NULL
         AND    mtrl.reference_detail_id = p_move_order_line_id;
    --END BUG 5194761


    -- ATF_J2
    -- Modified pregen_suggestions_csr cursor to get data from MOL also.
    CURSOR pregen_suggestions_csr IS
       SELECT mmtt.last_update_date
            , mmtt.transaction_temp_id
            , mmtt.locator_id mmtt_loc_id
            , mol.to_locator_id mol_loc_id
            , mol.backorder_delivery_detail_id
	    , mmtt.operation_plan_id
	    , mol.inspection_status
	 FROM   mtl_material_transactions_temp mmtt, mtl_txn_request_lines mol
	 WHERE  mmtt.lpn_id = l_lpn_id
	 -- Added following line for ATF_J
	 AND    mmtt.move_order_line_id = NVL(p_move_order_line_id, mmtt.move_order_line_id)
	 AND    mmtt.organization_id = p_org_id
	 -- Added for ATF_J to make sure dummy packing MMTT lines are not selected
	 AND    mmtt.transaction_action_id NOT IN (50, 51, 52)
	 AND    mmtt.move_order_line_id = mol.line_id
	 -- Bug# 3434940 - Performance Fixes
	 -- Also join against org and LPN for MOL to speed up the parsing
	 -- time for the query
	 AND    mol.organization_id = p_org_id
	 AND    mol.lpn_id = l_lpn_id;

    l_pregen_suggestion            pregen_suggestions_csr%ROWTYPE;

    -- End ATF_J2


    -- ATF_J
    -- It is not necessary to add P_move_order_line_ID to cursor suggestion_csr
    -- because lpn_csr is called within molines_csr and l_line_id is already restricted.


    CURSOR suggestions_csr IS
      SELECT transaction_header_id
           , transaction_temp_id
           , inventory_item_id
           , revision
           , subinventory_code
           , locator_id
           , transaction_quantity
           , transfer_to_location
           , NVL(standard_operation_id, 2)
           , task_priority
           , NVL(wms_task_type, 2)
           , operation_plan_id
           , move_order_line_id
  FROM   mtl_material_transactions_temp
  WHERE  move_order_line_id = l_line_id
  AND    transaction_action_id NOT IN (50, 51, 52)   --ATF_J3: to make sure dummy packing MMTT lines not selected

  ;

    -- ATF_J
    -- It is not necessary to add P_move_order_line_ID to cursor lpn_csr
    -- because lpn_csr is for creating move order lines when they do not exist,
    -- in which case P_move_order_line_ID will not be passed.

    CURSOR lpn_csr IS
      SELECT inventory_item_id
           , quantity
           , uom_code
           , lot_number
           , revision
           , cost_group_id
           , secondary_quantity -- Added for OPM convergance
           , secondary_uom_code -- Added for OPM convergance
      FROM   wms_lpn_contents
      WHERE  parent_lpn_id = p_lpn_id;

    l_m_item                       NUMBER;
    l_m_qty                        NUMBER;
    l_m_uom                        VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_m_lot                        VARCHAR2(80);
    l_m_rev                        VARCHAR2(3);
    l_m_hdr                        NUMBER;
    l_m_stat                       VARCHAR2(30);
    l_m_line                       NUMBER;
    l_m_sub                        VARCHAR2(10);
    l_m_loc                        NUMBER;
    l_cdock_flag                   NUMBER;
    l_ret_crossdock                NUMBER;
    l_td_crossdock                 VARCHAR2(3);
    -- ATFJ_2
    -- removed l_make_suggestions check.
    -- Because it is sufficient to determine if call rules engine or not
    -- based on mol.quantity_detailed and mol.quantity

    --     l_make_suggestions           VARCHAR2(2);
    l_regeneration_interval        NUMBER;
    l_last_update_date             DATE;
    l_pregen_putaway_tasks_flag    NUMBER;
    l_temp                         NUMBER;
    l_temp_update_date             DATE;
    l_wip_supply_type              NUMBER;
    l_lpn_context                  NUMBER;
    l_project_id                   NUMBER;
    l_task_id                      NUMBER;
    l_emp_id                       NUMBER;
    -- Following variables added in ATF_J

    l_atf_error_code               NUMBER;
    l_crossdock_missmatch_flag     VARCHAR2(1) := 'N';
    l_task_dispatched_flag         VARCHAR2(1) := 'N';
    l_op_plan_started_flag         VARCHAR2(1) := 'N';
    l_mmtt_staled_flag             VARCHAR2(1) := 'N';
    l_need_to_cleanup_pregen       VARCHAR2(1) := 'N';
    l_op_plan_instance_status      NUMBER;
    l_wlc_mol_missmatch_flag       VARCHAR2(1) := 'N';

      -- End variables added in ATF_J
    l_to_sub_code VARCHAR2(30);
    l_to_loc_id NUMBER;
    l_ref_detail_id NUMBER;--BUG 5194761

    -- Following variables added per GRAO's request
    -- used for inventory move by rules's engine
    l_quick_pick_flag              VARCHAR2(1) := 'N';
    -- End GRAO

    l_debug                        NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    -- Added for OPM convergance
    l_sec_qty                      NUMBER;
    l_sec_uom                      VARCHAR2(3);
    l_process_flag                 VARCHAR2(5); -- nsinghi. Added for GME-WMS Integration
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('suggestions_pub: In suggestions_pub');
    END IF;

    -- Bug# 2744186
    -- Set the savepoint
    SAVEPOINT suggestions_pub_sp;
    l_lpn_id := p_lpn_id;
    l_return_status := fnd_api.g_ret_sts_success;

    IF (l_lpn_id = 0) THEN
      l_lpn_id := NULL;
    END IF;

    l_rcount := 0;
    l_td_crossdock := 'N';

    -- Bug# 2750060
    -- Get the employee ID so we can populate
    -- the person_id column in WDT properly.
    BEGIN
      SELECT employee_id
      INTO   l_emp_id
      FROM   fnd_user
      WHERE  user_id = p_user_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: There is no employee tied to the user');
        END IF;

        l_emp_id := NULL;
    END;

    SELECT regeneration_interval
         , NVL(crossdock_flag, 2) cdock
         , pregen_putaway_tasks_flag
    INTO   l_regeneration_interval
         , l_cdock_flag
         , l_pregen_putaway_tasks_flag
    FROM   mtl_parameters
    WHERE  organization_id = p_org_id;

    -- Bug# 2752119
    -- Only check for crossdocking if the input parameter is set to 'Y'
    -- in case we are calling the Suggestions_PUB while performing an
    -- Express Drop with rules validation.  We don't want to check for
    -- crossdocking in that scenario


    --Bug# 2990197
    -- The second part of bug 2265157 was never propogated to the main
    -- branch. In suggestions_Pub (file WMSTKPTB.pls), before we call
    -- crossdock, we should check to make sure that the LPN context is
    -- only receiving or WIP.

    SELECT lpn_context
    INTO   l_lpn_context
    FROM   wms_license_plate_numbers
    WHERE  lpn_id = l_lpn_id
    AND    organization_id = p_org_id;

    -- ATF_J2 moved crossdock call to after cleanup_suggestions


    -- Check to see if mo lines exist already
    -- If not, we have to create it
    BEGIN
      SELECT 1
      INTO   l_rcount
      FROM   DUAL
      WHERE  EXISTS(
               SELECT 1
               FROM   mtl_txn_request_lines l, mtl_txn_request_headers h
               WHERE  l.lpn_id = l_lpn_id
               AND    l.line_id = NVL(p_move_order_line_id, l.line_id) -- added for ATF_J
               AND    NVL(l.quantity_delivered, 0) < l.quantity -- added for ATF_J
               AND    l.organization_id = p_org_id
               AND    l.header_id = h.header_id
               AND    l.line_status <> inv_globals.g_to_status_closed
               AND    h.move_order_type = inv_globals.g_move_order_put_away);
    --       AND Nvl(l.quantity_detailed,0) <l.quantity);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_rcount := 0;
    END;

    IF (l_rcount = 0) THEN
      IF (l_debug = 1) THEN
        mydebug('suggestions_pub: Move order does not exist. Creating new MO..');
      END IF;

      IF l_lpn_context <> 1 THEN
        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: Not an INV LPN');
        END IF;

        fnd_message.set_name('WMS', 'WMS_MO_NOT_FOUND');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF; -- (l_rcount=0)  -- fixed in ATF

    -- ATF_J5
    -- Added p_move_order_line_id check below.
    -- When item load an inventory LPN, putaway UI will create
    -- a move order line and pass that to suggestions_pub.
    -- In this case we shouldn't close that move order line and create line.
    IF l_lpn_context = 1 AND p_move_order_line_id IS NULL THEN
      -- ATF_J2
      -- Need to chek whether operation plan instance commenced or not
      -- If any MMTT lines has operation plan instance commenced, should not
      -- delete MMTT and close move order line.
      -- only applicable to J or above


       mydebug('suggestions_pub: Current release is above J.');
       OPEN pregen_suggestions_csr;

       LOOP
          FETCH pregen_suggestions_csr INTO l_pregen_suggestion;
          EXIT WHEN pregen_suggestions_csr%NOTFOUND;

          IF l_pregen_suggestion.operation_plan_id IS NOT NULL THEN
            IF (l_debug = 1) THEN
              mydebug('suggestions_pub:  Calling WMS_ATF_RUNTIME_PUB_APIS.Check_Plan_Status with:');
              mydebug('p_source_task_id => ' || l_pregen_suggestion.transaction_temp_id);
              mydebug('p_activity_type_id => ' || '1');
            END IF;

            wms_atf_runtime_pub_apis.check_plan_status(
              x_return_status        => l_return_status
            , x_msg_data             => l_msg_data
            , x_msg_count            => l_msg_count
            , x_error_code           => l_atf_error_code
            , x_plan_status          => l_op_plan_instance_status
            , p_source_task_id       => l_pregen_suggestion.transaction_temp_id
            , p_activity_type_id     => '1' -- inbound
            );

            IF (l_debug = 1) THEN
              mydebug('suggestions_pub:  After calling WMS_ATF_RUNTIME_PUB_APIS.Check_Plan_Status.');
              mydebug('x_return_status => ' || l_return_status);
              mydebug('x_msg_data => ' || l_msg_data);
              mydebug('x_msg_count => ' || l_msg_count);
              mydebug('x_error_code => ' || l_atf_error_code);
              mydebug('x_plan_status => ' || l_op_plan_instance_status);
            END IF;

            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('suggestions_pub: WMS_ATF_RUNTIME_PUB_APIS.Check_Plan_Status failed.');
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF; -- (l_return_status <> fnd_api.g_ret_sts_success)

            IF l_op_plan_instance_status IS NOT NULL
               AND l_op_plan_instance_status <> 1 -- not pending status
                                                  THEN
              l_op_plan_started_flag := 'Y';
              EXIT;
            END IF; -- (l_op_plan_instance_status IS NOT NULL)
          END IF; -- IF l_pregen_suggestion.operation_plan_id IS NOT NULL
       END LOOP;

       CLOSE pregen_suggestions_csr;

      -- End ATF_J2

      -- ATF_J2
      -- only delete MMTT/WDT, close MOL, when there is no operation plan instance commenced

      IF l_op_plan_started_flag = 'Y' THEN
        NULL;
      --      l_make_suggestions := 'N';  --??

      ELSE
        --      l_make_suggestions := 'Y';

        SELECT subinventory_code
             , locator_id
        INTO   l_m_sub
             , l_m_loc
        FROM   wms_license_plate_numbers
        WHERE  lpn_id = l_lpn_id;

        -- Need to close those old MOL lines
        -- for inventory LPN
        -- Bug 2271470

        --Also delete corresponding WDT and MMTTs. bug # 2503594
        DELETE FROM wms_dispatched_tasks
              WHERE transaction_temp_id IN(
                      SELECT transaction_temp_id
                      FROM   mtl_material_transactions_temp
                      WHERE  move_order_line_id IN(
                               SELECT mol.line_id
                               FROM   mtl_txn_request_lines mol
                               WHERE  mol.lpn_id = l_lpn_id
                               AND    mol.line_id = NVL(p_move_order_line_id, mol.line_id) -- added for ATF_J
                               AND    mol.organization_id = p_org_id
                               AND    mol.quantity_detailed > 0
                               AND    EXISTS(
                                        SELECT 1
                                        FROM   mtl_txn_request_headers moh
                                        WHERE  mol.header_id = moh.header_id
                                        AND    moh.move_order_type = inv_globals.g_move_order_put_away)));

        -- ATF_J2
        -- Need to delete MTLT before deleting MMTT
        -- Need tuning ???


        DELETE FROM mtl_transaction_lots_temp mtlt
              WHERE EXISTS(
                      SELECT 1
                      FROM   mtl_material_transactions_temp mmtt
                      WHERE  mtlt.transaction_temp_id = mmtt.transaction_temp_id
                      AND    mmtt.move_order_line_id IN(
                               SELECT mol.line_id
                               FROM   mtl_txn_request_lines mol
                               WHERE  mol.lpn_id = l_lpn_id
                               AND    mol.line_id = NVL(p_move_order_line_id, mol.line_id) -- added for ATF_J
                               AND    mol.organization_id = p_org_id
                               AND    mol.quantity_detailed > 0
                               AND    EXISTS(
                                        SELECT 1
                                        FROM   mtl_txn_request_headers moh
                                        WHERE  mol.header_id = moh.header_id
                                        AND    moh.move_order_type = inv_globals.g_move_order_put_away)));

        DELETE FROM mtl_material_transactions_temp
              WHERE move_order_line_id IN(
                      SELECT mol.line_id
                      FROM   mtl_txn_request_lines mol
                      WHERE  mol.lpn_id = l_lpn_id
                      AND    mol.line_id = NVL(p_move_order_line_id, mol.line_id) -- added for ATF_J
                      AND    mol.organization_id = p_org_id
                      AND    mol.quantity_detailed > 0
                      AND    EXISTS(SELECT 1
                                    FROM   mtl_txn_request_headers moh
                                    WHERE  mol.header_id = moh.header_id
                                    AND    moh.move_order_type = inv_globals.g_move_order_put_away));

        UPDATE mtl_txn_request_lines mol
        SET mol.line_status = inv_globals.g_to_status_closed
        WHERE  mol.lpn_id = l_lpn_id
        AND    mol.line_id = NVL(p_move_order_line_id, mol.line_id) -- added for ATF_J
        AND    mol.organization_id = p_org_id
--        AND    mol.quantity_detailed > 0    -- removed in ATF_J3
        AND    EXISTS(SELECT 1
                      FROM   mtl_txn_request_headers moh
                      WHERE  mol.header_id = moh.header_id
                      AND    moh.move_order_type = inv_globals.g_move_order_put_away);

        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: after getting sub and loc');
          mydebug('suggestions_pub: Loc' || l_m_loc);
          mydebug('suggestions_pub: Sub' || l_m_sub);
        END IF;

        OPEN lpn_csr;

        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: Opened lpncsr');
        END IF;

        LOOP
          FETCH lpn_csr INTO
            l_m_item,
            l_m_qty,
            l_m_uom,
            l_m_lot,
            l_m_rev,
            l_lpn_cg_id,
            l_sec_qty,
            l_sec_uom;
          EXIT WHEN lpn_csr%NOTFOUND;

          IF (l_debug = 1) THEN
            mydebug('suggestions_pub: lpn loop');
            mydebug('suggestions_pub: lot' || l_m_lot);
          END IF;

          IF l_m_lot = '-999' THEN
            l_m_lot := NULL;
          END IF;

          IF l_m_rev = '-999' THEN
            l_m_rev := NULL;
          END IF;

          SELECT mil.project_id
               , mil.task_id
          INTO   l_project_id
               , l_task_id
          FROM   mtl_item_locations mil
          WHERE  mil.inventory_location_id = l_m_loc
          AND    mil.organization_id = p_org_id
          AND    mil.subinventory_code = l_m_sub;

          -- Call create_mo
          IF (l_debug = 1) THEN
            mydebug('suggestions_pub: Calling create_mo');
          END IF;

          wms_task_dispatch_put_away.create_mo(
            p_org_id                         => p_org_id
          , p_inventory_item_id              => l_m_item
          , p_qty                            => l_m_qty
          , p_uom                            => l_m_uom
          , p_lpn                            => l_lpn_id
          , p_project_id                     => l_project_id
          , p_task_id                        => l_task_id
          , p_reference                      => NULL
          , p_reference_type_code            => NULL
          , p_reference_id                   => NULL
          , p_lot_number                     => l_m_lot
          , p_revision                       => l_m_rev
          , p_header_id                      => l_m_hdr
          , p_sub                            => l_m_sub
          , p_loc                            => l_m_loc
          , x_line_id                        => l_m_line
          , p_inspection_status              => NULL
          , p_transaction_type_id            => 64
          , p_transaction_source_type_id     => 4
          , p_wms_process_flag               => NULL
          , x_return_status                  => l_return_status
          , x_msg_count                      => l_msg_count
          , x_msg_data                       => l_msg_data
          , p_from_cost_group_id             => l_lpn_cg_id
          , p_sec_qty                        => l_sec_qty  -- Added for OPM Convergance
          , p_sec_uom                        => l_sec_uom  -- Added for OPM Convergance
          );
          -- bug fix 2271470
          l_m_hdr := NULL;
          fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);

          IF (l_msg_count = 0) THEN
            IF (l_debug = 1) THEN
              mydebug('suggestions_pub: Successful');
            END IF;
          ELSIF(l_msg_count = 1) THEN
            IF (l_debug = 1) THEN
              mydebug('suggestions_pub: Not Successful');
              mydebug('suggestions_pub: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('suggestions_pub: Not Successful2');
            END IF;

            FOR i IN 1 .. l_msg_count LOOP
              l_msg_data := fnd_msg_pub.get(i, 'F');

              IF (l_debug = 1) THEN
                mydebug('suggestions_pub: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
              END IF;
            END LOOP;
          END IF;

          IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            fnd_message.set_name('WMS', 'WMS_TD_CMO_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            fnd_message.set_name('WMS', 'WMS_TD_CMO_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          IF (l_debug = 1) THEN
            mydebug('suggestions_pub: Line ID created');
            mydebug('suggestions_pub: ' || l_m_line);
          END IF;
        END LOOP;

        CLOSE lpn_csr;
      END IF; -- (l_op_plan_started_flag = 'Y') added for ATF_J2

      IF p_drop_type = 'MD' THEN

        -- Update the move order lines with the user inputted sub/loc.
        -- Also null out the quantity detailed
	 IF (l_debug = 1) THEN
	    mydebug('Manual Drop: Updating Move orders to : Sub: ' || p_subinventory || ' loc : '||p_locator_id );
	 END IF;

	 UPDATE mtl_txn_request_lines mol
	   SET    to_subinventory_code = p_subinventory
	   , to_locator_id = p_locator_id
	   , quantity_detailed = NULL
	   WHERE  organization_id = p_org_id
	   AND    lpn_id = l_lpn_id
	   AND    mol.line_status <> inv_globals.g_to_status_closed;
      END IF;

    END IF; -- (l_lpn_context = 1)

    IF (l_debug = 1) THEN
      mydebug('suggestions_pub: after lpn crsr loop');
    END IF;

    -- Code to check for pregenerated putaway allocations
    -- The corresponding pseudo code for that is as follows:
    --
    -- For a given Equipment, LPN, user, org
    -- If there are putaway suggestions already created for this LPN
    --  if (current time - update date >   regeneration interval)
    --      or (l_pregen_putaway_tasks_flag = 0)
    --         Delete suggestions and call Putaway Rules Engine again.
    --         Delete all MMTT lines for that LPN and set detailed quantity
    --                           = 0 in MO line
    --         l_make_suggestions := Y;
    --
    --  Else
    --     Dont call suggestions API
    --     l_make_suggestions := N;
    --Else
    --  l_make_suggestions := Y
    --
    --If l_make_suggestions = Y
    --  Proceed as before in calling suggestions API
    --Else
    --  Do not create suggestions
    --

    IF (l_debug = 1) THEN
      mydebug('suggestions_pub: Code to check for pregenerated putaway suggestions');
    END IF;

    l_rcount := 0;
    l_temp_update_date := SYSDATE;

    -- ATF_J2
    -- Rewrite the logic for deleting pre-generated MMTT
    --
    -- 1. If LPN context is INV, do not need to delete pregenerate, because MMTT deletion has been
    --    taken care of previously for inventory LPNs.
    --
    -- 2. Open and LOOP through pregen_suggestions_csr, which will decide for this
    --    LPN/MOL combination do we need to cleanup suggestions or not,
    --    by setting l_Need_to_cleanup_pregen flag.
    --
    --
    --
    --    2.1 If mol.backorder_delivery_detail_id IS NOT NULL (crossdocked)
    --           AND MOL.to_locator_id <> MMTT.locator_id (and crossdock doesnot match with MMTT)
    --          THEN
    --              set l_crossdock_missmatch_flag Yes
    --
    --         END IF;
    --       If MOL crossdock locator doesnot match MMTT's destination locator,
    --       for sure there would not be task or operation plan commence, therefore
    --       does not need to check those.
    --
    --    2.2 If Task has commenced, set l_task_dispatched_flag
    --
    --    2.3 If operation plan has commenced, set l_op_plan_started_flag
    --
    --    2.4 If task staled and not crossdock, set l_mmtt_staled_flag
    --
    -- 3. After the loop,
    --      set l_Need_to_cleanup_prege based on the flags set.
    --
    --
    -- 4. If l_Need_to_cleanup_prege is YES, call wms_putaway_suggestions.cleanup_suggestions, passing lpn_id and move_order_line_id

    IF l_lpn_context <> 1 THEN
      IF pregen_suggestions_csr%ISOPEN THEN
        CLOSE pregen_suggestions_csr;
      END IF;

      OPEN pregen_suggestions_csr;

      LOOP
        FETCH pregen_suggestions_csr INTO l_pregen_suggestion;
        EXIT WHEN pregen_suggestions_csr%NOTFOUND;

  l_rcount := l_rcount + 1;

        /*
               -- 2.1 Check if MOL crossdock locator doesnot match MMTT's destination locator.

               IF l_pregen_suggestion.backorder_delivery_detail_id IS NOT NULL -- This MOL has been back ordered
                 AND l_pregen_suggestion.mol_loc_id <> l_pregen_suggestion.mmtt_loc_id -- crossdock locator does not match pregenerated MMTT.locator
                 AND l_crossdock_missmatch_flag = 'N'
                 THEN
            l_crossdock_missmatch_flag := 'Y';
            EXIT;
            -- we can only exit in this check, because crossdock mismatch has the highest
            -- precedence.

               END IF;   --(l_pregen_suggestion.backorder_delivery_detail_id IS NOT NULL)

                 */

        -- 2.2 Check if task has been dispatched.

        IF l_task_dispatched_flag = 'N' THEN
          BEGIN
            SELECT '1'
            INTO   wdt_exist
            FROM   DUAL
            WHERE  EXISTS(SELECT transaction_temp_id
                          FROM   wms_dispatched_tasks
                          WHERE  transaction_temp_id = l_pregen_suggestion.transaction_temp_id);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              wdt_exist := '2';
          END;

          IF (wdt_exist = '1') THEN
            -- some tasks are already dispatched
            -- so nothing needs to be done with pregenerated suggestions
            l_task_dispatched_flag := 'Y';
            EXIT;
          END IF; -- (wdt_exist = '1')
        END IF; -- l_task_dispatched_flag = 'N'

  -- 2.3 check if operation plan has commenced

        IF l_pregen_suggestion.operation_plan_id IS NOT NULL THEN
	   mydebug('suggestions_pub: Current release is above J.');

	   IF l_op_plan_started_flag = 'N' THEN
	      IF (l_debug = 1) THEN
		 mydebug('suggestions_pub:  Calling WMS_ATF_RUNTIME_PUB_APIS.Check_Plan_Status with:');
		 mydebug('p_source_task_id => ' || l_pregen_suggestion.transaction_temp_id);
	      END IF;

	      wms_atf_runtime_pub_apis.check_plan_status
		(
		 x_return_status        => l_return_status
		 , x_msg_data             => l_msg_data
		 , x_msg_count            => l_msg_count
		 , x_error_code           => l_atf_error_code
		 , x_plan_status          => l_op_plan_instance_status
		 , p_source_task_id       => l_pregen_suggestion.transaction_temp_id
		 , p_activity_type_id     => '1' -- inbound
		 );

	      IF (l_debug = 1) THEN
		 mydebug('suggestions_pub:  After calling WMS_ATF_RUNTIME_PUB_APIS.Check_Plan_Status.');
		 mydebug('x_return_status => ' || l_return_status);
		 mydebug('x_msg_data => ' || l_msg_data);
		 mydebug('x_msg_count => ' || l_msg_count);
		 mydebug('x_error_code => ' || l_atf_error_code);
		 mydebug('x_plan_status => ' || l_op_plan_instance_status);
	      END IF;

	      IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
		 IF (l_debug = 1) THEN
		    mydebug('suggestions_pub: WMS_ATF_RUNTIME_PUB_APIS.Check_Plan_Status failed.');
		 END IF;

		 RAISE fnd_api.g_exc_error;
	      END IF; -- (l_return_status <> fnd_api.g_ret_sts_success)

	      IF l_op_plan_instance_status IS NOT NULL
		AND l_op_plan_instance_status <> 1 -- not pending status
		THEN
		 l_op_plan_started_flag := 'Y';
		 EXIT;
	      END IF; -- (l_op_plan_instance_status IS NOT NULL)
	   END IF; -- l_op_plan_started_flag = 'N'
        END IF; -- (l_pregen_suggestion.operation_plan_id

        IF (
            ((SYSDATE - l_pregen_suggestion.last_update_date) * 24 * 60 > l_regeneration_interval)
            OR -- MMTT line staled
               l_pregen_putaway_tasks_flag <> 1  -- ATF_J5: also treat MMTT lines other than pre-generated as stale. This is to cover what cleanup_partial_putaway used to do
           ) -- MMTT was not generated by pregenerate (???)
           AND l_mmtt_staled_flag = 'N' THEN
	   IF (l_pregen_suggestion.backorder_delivery_detail_id IS NULL -- not a backordered line
	       AND Nvl(l_pregen_suggestion.inspection_status, 2) <> 1) THEN  -- not a line that requires inspection i.e. manually pre-gen
            l_mmtt_staled_flag := 'Y';
          END IF; -- (l_pregen_suggestion.backorder_delivery_detail_id IS NULL)
        END IF; -- (Sysdate - l_pregen_suggestion.last_update_date)*24*60
      END LOOP;

      CLOSE pregen_suggestions_csr;

      IF (l_debug = 1) THEN
        mydebug(' suggestions_pub: l_crossdock_missmatch_flag = ' || l_crossdock_missmatch_flag);
        mydebug(' suggestions_pub: l_task_dispatched_flag = ' || l_task_dispatched_flag);
        mydebug(' suggestions_pub: l_op_plan_started_flag = ' || l_op_plan_started_flag);
        mydebug(' suggestions_pub: l_mmtt_staled_flag = ' || l_mmtt_staled_flag);
      END IF;

      IF l_task_dispatched_flag = 'Y' THEN
        l_need_to_cleanup_pregen := 'N';
      ELSIF l_op_plan_started_flag = 'Y' THEN
        l_need_to_cleanup_pregen := 'N';
      ELSIF l_mmtt_staled_flag = 'Y' THEN
        l_need_to_cleanup_pregen := 'Y';
      END IF;

      IF (l_debug = 1) THEN
        mydebug('suggestions_pub: l_need_to_cleanup_pregen = ' || l_need_to_cleanup_pregen);
      END IF;

      IF l_need_to_cleanup_pregen = 'Y' OR  -- pregenerated MMTT needs cleanup
	l_rcount = 0  -- there is no pregenerated MMTT
	THEN

	 IF l_rcount <> 0 THEN -- there are pregenerated MMTT lines, therefore do need to cleanup
	    IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: calling cleanup_suggestions (autonomous_transaction) with: ');
	       mydebug('p_lpn_id = ' || l_lpn_id);
	       mydebug('p_org_id = ' || p_org_id);
	       mydebug('p_move_order_line_id = '||p_move_order_line_id);
	    END IF;


	    -- Modified the following for bug fix 3866880
	    -- Decommission the cleanup_suggestions
	    -- api with autonomous commit, which is conflicting with
	    -- MMTT and MOL update from inbound UI for item load.
	    -- The original need for autonomous cleanup_suggestions
	    -- is satisfied by passing p_for_manual_drop => true
	    -- into abort_operation_instance .

	    wms_putaway_suggestions.cleanup_suggestions
	      (
	       p_lpn_id                 => l_lpn_id
	       , p_org_id                 => p_org_id
	       , x_return_status          => l_return_status
	       , x_msg_count              => x_msg_count
	       , x_msg_data               => x_msg_data
	       , p_move_order_line_id     => p_move_order_line_id
	       ); --added for ATF_J2

	    IF (l_debug = 1) THEN
	       mydebug(' suggestions_pub: After calling wms_putaway_suggestions.cleanup_suggestions ');
	       mydebug('x_return_status = ' || l_return_status);
	       mydebug('x_msg_count = ' || x_msg_count);
	       mydebug('x_msg_data = ' || x_msg_data);
	    END IF;

	    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	       IF (l_debug = 1) THEN
		  mydebug(' suggestions_pub: wms_putaway_suggestions.cleanup_suggestions failed');
	       END IF;

	       RAISE fnd_api.g_exc_error;
	    END IF;

	 END IF; --  IF l_rcount <> 0 THEN

       ELSE     -- (l_need_to_cleanup_pregen = 'Y')
	 --      l_make_suggestions := 'N';
	 NULL;
      END IF; -- (l_need_to_cleanup_pregen = 'Y')
    END IF; -- (l_lpn_context <> 1)


    -- Before creating suggestions
    -- verify if MOL and LPN contents match or not
    -- Only compare if MOL and LPN content record has the same UOM code, which should always be true


    IF l_lpn_context <> 1 OR p_drop_type IS NULL
      OR p_drop_type <> 'IIL' THEN
       -- Do not check for mismatch for inventory item load
       -- because for inventory LPN item load will create move order line
       -- on the fly for the loaded quantity, which will not match the quantity in LPN contents.
      BEGIN

       SELECT 'Y'
	 INTO l_wlc_mol_missmatch_flag
	 FROM dual
	 WHERE exists
	 (SELECT wlc.inventory_item_id
	  FROM
	  (SELECT parent_lpn_id,
	   SUM(quantity) quantity,
	   uom_code,
	   inventory_item_id,
	   revision,
	   lot_number,
	   organization_id--BUG 4607833
	   FROM
	   wms_lpn_contents
	   GROUP BY parent_lpn_id, inventory_item_id, revision, lot_number,uom_code,organization_id--BUG 4607833
	   ) wlc,   -- sub-query is necessary because there could be more than one wlc record for the same inventory_item_id, revision, lot_number
	  mtl_txn_request_lines mol
	  WHERE wlc.parent_lpn_id = mol.lpn_id
	  AND wlc.inventory_item_id = mol.inventory_item_id
--	  AND wlc.uom_code = mol.uom_code  -- Bug fix 3200526
	  AND wlc.organization_id = mol.organization_id --Bug 4607833
	  AND (wlc.revision = mol.revision
	       OR(wlc.revision IS NULL AND mol.revision IS NULL)
	       )
	  AND (wlc.lot_number = mol.lot_number
	       OR(wlc.lot_number IS NULL AND mol.lot_number IS NULL)
	       )
	  AND mol.line_status <> 5   -- not closed
	  AND mol.lpn_id = l_lpn_id
	  --    AND mol.line_id = Nvl(p_move_order_line_id, mol.line_id)  -- comment out in ATF_J3, we should only check mismatch based on LPN, because in item load pack/unpack happens after receiving TM call
          -- Bug fix 3200526 If the MOLs for this LPN have different UOMs,
          -- do not consider it mismatch, because we really don't want to call
          -- UOM converstion for this pre-cautionary check.
	GROUP BY wlc.inventory_item_id, wlc.lot_number, wlc.revision, wlc.uom_code
	HAVING MIN(wlc.quantity) <> SUM(mol.quantity-Nvl(mol.quantity_delivered, 0))
         AND MIN(mol.UOM_CODE) = MAX(mol.UOM_CODE)
         AND wlc.UOM_CODE = MIN(mol.UOM_CODE)
       );

      EXCEPTION
	 WHEN OTHERS THEN
	    l_wlc_mol_missmatch_flag := 'N';
      END;

      IF l_wlc_mol_missmatch_flag = 'Y' THEN

	 IF (l_debug = 1) THEN
	    mydebug('suggestions_pub: There is a mismatch between LPN content and MOL quantity.');
	 END IF;

	-- 13995073 starts

	fnd_message.set_name('WMS', 'WMS_MOL_WLC_QTY_MISMATCH');
        fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;
      END IF;   -- IF l_wlc_mol_missmatch_flag = 'Y'
	--13995073 ends

    END IF; -- IF l_lpn_context <> 1 THEN


    -- End ATFJ_2


    OPEN molines_csr;

    LOOP
      FETCH molines_csr INTO l_line_id, l_ref_id, l_txn_source_type_id, l_quantity_detailed, l_quantity
     , l_backorder_delivery_detail_id, l_crossdock_type, l_to_sub_code, l_to_loc_id, l_ref_detail_id;
      EXIT WHEN molines_csr%NOTFOUND;

        -- ATF_J2
        -- Only need to call crossdock if we  cleanup suggestions and
        -- create new suggestions.

      --{{
      --  When move order line is crossdocked but destination sub/loc not stamped
      --  need to do check crossdock again.
      --  Need to test the case multiple MOL in the same LPN since it is called by MOL here
      --}}

      IF (l_debug = 1) THEN
	mydebug('suggestions_pub: p_move_order_line_id:'||p_move_order_line_id);
      END IF;

      --BUG 5194761: Do not call crossdock API if this is called from Item Load
      --(p_move_order_line_id is NULL), because it would be called from
      -- WMSTKILB pre_process_load
      IF (p_move_order_line_id IS NULL
          AND ((l_cdock_flag = 1  -- WIP, op-xdock enabled, and x-dock not happened
	        AND p_check_for_crossdock = 'Y'
	        AND l_lpn_context = 2
	        AND l_backorder_delivery_detail_id IS NULL)
	       OR
               (l_lpn_context = 3  -- RCV, xdock happened, but staging lane suggestion not successful
	        AND l_backorder_delivery_detail_id IS NOT NULL
		AND (l_to_sub_code IS NULL OR l_to_loc_id IS NULL))
	    ))
	       THEN
	 IF (l_debug = 1) THEN
	    mydebug('suggestions_pub: Crossdock enabled and check is yes');
	 END IF;

	 -- Call the cross dock API
	 wms_cross_dock_pvt.crossdock(
				      p_org_id                 => p_org_id
				      , p_lpn                    => l_lpn_id
				      , x_ret                    => l_ret_crossdock
				      , x_return_status          => l_return_status
				      , x_msg_count              => l_msg_count
				      , x_msg_data               => l_msg_data
				      , p_move_order_line_id     => l_line_id
				      ); -- added for ATF_J

	 IF (l_debug = 1) THEN
            mydebug('suggestions_pub: Finished calling crossdock API');
	 END IF;

	 -- See if there are any error messages returned from the API
	 fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);

	 IF (l_msg_count = 0) THEN
            IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: Successful');
            END IF;
          ELSIF(l_msg_count = 1) THEN
            IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: Not Successful');
	       mydebug('suggestions_pub: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
            END IF;
          ELSE
            IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: Not Successful2');
            END IF;

            FOR i IN 1 .. l_msg_count LOOP
	       l_msg_data := fnd_msg_pub.get(i, 'F');

	       IF (l_debug = 1) THEN
		  mydebug('suggestions_pub: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
	       END IF;
            END LOOP;
	 END IF;

	 -- Bug# 2744186
	 -- Check the return status from the API call
	 -- Throw an exception if the call was not completed successfully
	 IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: Success returned from WMS_Cross_Dock_Pvt.crossdock API');
            END IF;
          ELSE
            IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: Failure returned from WMS_Cross_Dock_Pvt.crossdock API');
            END IF;

            RAISE fnd_api.g_exc_error;
	 END IF;

	 -- Check the cross dock return value
	 IF l_ret_crossdock = 1 THEN
            IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: Nothing to Crossdock');
            END IF;
          ELSIF l_ret_crossdock = 0 THEN
            IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: CrossDock Succeeded');
            END IF;

            l_td_crossdock := 'Y';
          ELSE
            -- DO SOMETHING
            l_td_crossdock := 'N';

            IF (l_debug = 1) THEN
	       mydebug('suggestions_pub: CrossDock Error');
            END IF;
	 END IF;

	 x_crossdock := l_td_crossdock;
       ELSE
	 IF (l_debug = 1) THEN
            mydebug('suggestions_pub: Crossdock Not enabled or no check');
	 END IF;
      END IF; -- (l_cdock_flag = 1 AND p_check_for_crossdock = 'Y')
    END LOOP;

    CLOSE molines_csr;

    OPEN molines_csr;
    LOOP
      FETCH molines_csr INTO l_line_id, l_ref_id, l_txn_source_type_id, l_quantity_detailed, l_quantity
     , l_backorder_delivery_detail_id, l_crossdock_type, l_to_sub_code, l_to_loc_id, l_ref_detail_id;
      EXIT WHEN molines_csr%NOTFOUND;

      IF l_quantity_detailed IS NULL THEN
        l_quantity_detailed := 0;
      END IF;

      IF (l_debug = 1) THEN
        mydebug('suggestions_pub: Line ID' || l_line_id);
        mydebug('suggestions_pub: l_quantity_detailed' || l_quantity_detailed);
        mydebug('suggestions_pub: l_quantity' || l_quantity);
        mydebug('suggestions_pub: l_ref_detail_id' || l_ref_detail_id);
      END IF;


      IF (l_ref_detail_id IS NOT NULL) THEN
         BEGIN
           UPDATE mtl_txn_request_lines
            SET  reference_detail_id = NULL
           WHERE line_id = l_line_id;
         EXCEPTION
           WHEN OTHERS THEN
            IF (l_debug = 1) THEN
              mydebug('suggestions_pub: Error nulling out mtrl.ref_detail_id. SQLERRM:'||SQLERRM);
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

         IF (l_debug = 1) THEN
           mydebug('suggestions_pub: Successfully Null out mtrl.ref_detail_id');
         END IF;
      END IF;

      -- ATFJ_2
      -- removed l_make_suggestions check.
      -- Because it is sufficient to determine if call rules engine or not
      -- based on mol.quantity_detailed and mol.quantity

      IF NVL(l_quantity_detailed, 0) < NVL(l_quantity, 0) THEN
        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: Before PPE');
          mydebug('suggestions_pub: MOve order line ID ' || l_line_id);
        END IF;

        IF l_lpn_context = 1 THEN
	   IF (l_debug = 1) THEN
	      mydebug('suggestions_pub: Clearing qty. tree Cache');
	      --call clear qty tree cache for inventory lpns.
	   END IF;
	   inv_quantity_tree_pvt.clear_quantity_cache;

	   -- added per GRAO's request
	   -- inventory move for rules' engine

	   IF (l_debug = 1) THEN
	      mydebug('suggestions_pub: Current release is above J. set l_quick_pick_flag to Y');
	      l_quick_pick_flag := 'Y';
	   END IF;

        END IF;

        inv_ppengine_pvt.create_suggestions(
          p_api_version             => l_api_version_number
        , p_init_msg_list           => l_init_msg_list
        , p_commit                  => fnd_api.g_false
        , p_validation_level        => fnd_api.g_valid_level_full
        , x_return_status           => l_return_status
        , x_msg_count               => x_msg_count
        , x_msg_data                => x_msg_data
        , p_transaction_temp_id     => l_line_id
        , p_reservations            => l_mtl_reservation
        , p_suggest_serial          => l_serial_flag
        , p_quick_pick_flag         => l_quick_pick_flag
        );
--        fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);

        IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            mydebug('suggestions_pub: unexpected error in inv_ppengine_pvt.create_suggestions');
          END IF;

          fnd_message.set_name('WMS', 'WMS_ALLOCATE_FAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            mydebug('suggestions_pub: expected error in inv_ppengine_pvt.create_suggestions');
          END IF;

          fnd_message.set_name('WMS', 'WMS_ALLOCATE_FAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: After calling inv_ppengine_pvt.create_suggestions');
          mydebug('suggestions_pub: l_return_status = ' || l_return_status);
        END IF;

        -- Update Qty detailed in Mtl_txn_request_lines
        -- Bug fix 2271470
        -- Need to consider quantity_delivered

         UPDATE mtl_txn_request_lines mol
        SET mol.quantity_detailed = (SELECT NVL(mol.quantity_delivered, 0) + NVL(SUM(mmtt.transaction_quantity), 0)
                                     FROM   mtl_material_transactions_temp mmtt
                                     WHERE  mmtt.move_order_line_id = l_line_id
				     AND transaction_action_id NOT IN (50, 51, 52)
				     AND NOT (transaction_action_id = 2
					      AND transaction_source_type_id = 13) -- this is to make sure the dummy MMTT erwin created does not contribute this calculation
                                     ),
	    mol.secondary_quantity_detailed = (SELECT NVL(mol.secondary_quantity_delivered, 0) + NVL(SUM(mmtt.secondary_transaction_quantity), 0)
                                     FROM   mtl_material_transactions_temp mmtt
                                     WHERE  mmtt.move_order_line_id = l_line_id
				     AND transaction_action_id NOT IN (50, 51, 52)
				     AND NOT (transaction_action_id = 2
					      AND transaction_source_type_id = 13) -- this is to make sure the dummy MMTT erwin created does not contribute this calculation
				              )   -- Bug# 7716519,Need to update sec_qty_detailed after calling suggestions api

        WHERE  mol.line_id = l_line_id;

        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: After UPdate');
        END IF;
      END IF; -- Nvl(l_quantity_detailed,0) < Nvl(l_quantity,0)

      l_num_of_rows := 0;
      OPEN suggestions_csr;

      LOOP
        FETCH suggestions_csr INTO l_transaction_header_id
       , l_transaction_temp_id
       , l_inventory_item_id
       , l_revision
       , l_subinventory_code
       , l_locator_id
       , l_transaction_quantity
       , l_transfer_to_location
       , l_std_op_id
       , l_priority
       , l_wms_task_type
       , l_operation_plan_id
       , l_move_order_line_id;

        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: Before crs Exit');
        END IF;

        EXIT WHEN suggestions_csr%NOTFOUND;

        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: After crs Exit ');
          mydebug('suggestions_pub: l_crossdock_type ' || l_crossdock_type);
          mydebug('suggestions_pub:l_backorder_delivery_detail_id  ' || l_backorder_delivery_detail_id);
        END IF;

	-- {{
	--  removed update WIP related info into MMTT, this should have been take care of by rules engine
	-- }}

        -- Check mtl statuses
        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: Checking mtl_status');
        END IF;

        wms_task_dispatch_put_away.check_mmtt_mtl_status(
          p_temp_id           => l_transaction_temp_id
        , p_org_id            => p_org_id
        , x_mtl_status        => l_mtl_status
        , x_return_status     => l_return_status
        , x_msg_count         => l_msg_count
        , x_msg_data          => l_msg_data
        );

        IF (l_debug = 1) THEN
          mydebug('suggestions_pub: mtl_status = ' || l_mtl_status);
        END IF;

        IF l_mtl_status = 1 THEN
          IF (l_debug = 1) THEN
            mydebug('suggestions_pub: Invalid Status');
          END IF;

          -- Bug# 2743821
          -- Commenting out the following rollback statement
          -- since the savepoint is never set.  Also setting a
          -- different error message since the one used initially
          -- doesn't seem to be a valid seeded message.
          --ROLLBACK TO mtl_stat_chk;
          --FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_STATUS');
          fnd_message.set_name('WMS', 'WMS_INVALID_LPN_ITEM_STATUS');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

   /* nsinghi - GME-WMS Integration. Added the following select stmt to determine if Process Org.
   Also added check in If statement to not refer to Wip_Lpn_Completions table for discrete Orgs.
   Also added the If statement to update transaction_source_id in MMTT for Process Orgs. */

        SELECT NVL(process_enabled_flag, 'N') INTO l_process_flag
        FROM mtl_parameters WHERE organization_id = p_org_id;

        -- Update MMTT for WIP
        IF (l_txn_source_type_id = 5 AND l_process_flag = 'N') THEN
          SELECT completion_transaction_id
               , DECODE(wip_entity_type, 4, 'Y', 'N')
               , wip_entity_id
          INTO   l_completion_txn_id
               , l_flow_schedule
               , l_transaction_source_id
          FROM   wip_lpn_completions
          WHERE  header_id = l_ref_id;

          UPDATE mtl_material_transactions_temp
          SET completion_transaction_id = l_completion_txn_id
            , flow_schedule = l_flow_schedule
            , transaction_source_id = l_transaction_source_id
          WHERE  transaction_temp_id = l_transaction_temp_id;
        END IF;

        /* nsinghi - added the If statement to update transaction_source_id in MMTT for Process Orgs. */
        IF (l_txn_source_type_id = 5 AND l_process_flag = 'Y') THEN
           SELECT txn_source_id INTO l_transaction_source_id
           FROM mtl_txn_request_lines
           WHERE line_id = l_line_id;

           UPDATE mtl_material_transactions_temp
           SET flow_schedule = 'N'
             , transaction_source_id = l_transaction_source_id
           WHERE  transaction_temp_id = l_transaction_temp_id;
        END IF;

        -- ATF_J:
        -- Following two apis,
        -- operation_plan_assignment and init_op_plan_instance,
        -- are only called if customer is at patchset J or above.
        -- Also, only need to call these APIs if current MMTT does not yet have
        -- operation_plan_id stamped.

        --We should not call the ATF APIs in case of Manual Drop
        --Hence adding a check for drop type

        IF ( p_drop_type IS NULL OR p_drop_type <> 'MD') THEN
	   mydebug('suggestions_pub: Current release is above J.');

          IF l_operation_plan_id IS NULL
             AND l_lpn_context = 3 THEN -- LPN context resides in receiving
            mydebug(
              ' operation_plan_id is null on MMTT and this is a receiving LPN, assign operation plan and initialize operation plan instance.'
            );
            --Following API assigns operation plan to an MMTT
            mydebug('suggestions_pub: Before calling wms_rule_pvt.assign_operation_plan with following parameters: ');
            mydebug('p_task_id = ' || l_transaction_temp_id);
            mydebug('p_activity_type_id = ' || 1);
            mydebug('p_organization_id = ' || p_org_id);
            wms_atf_util_apis.assign_operation_plan(
              p_api_version          => 1.0
            , x_return_status        => l_return_status
            , x_msg_count            => l_msg_count
            , x_msg_data             => l_msg_data
            , p_task_id              => l_transaction_temp_id
            , p_activity_type_id     => 1
            , -- Inbound
              p_organization_id      => p_org_id
            );
            mydebug('suggestions_pub: After calling wms_rule_pvt.assign_operation_plan');
            mydebug('l_return_status = ' || l_return_status);

            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('suggestions_pub: wms_rule_pvt.assign_operation_plan failed.');
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF; -- (l_return_status <> fnd_api.g_ret_sts_success)

                    --Following API initializes the operation plan instance

            mydebug('suggestions_pub: Before calling wms_op_runtime_pub_apis.init_op_plan_instance with following parameters: ');
            mydebug('p_source_task_id = ' || l_transaction_temp_id);
            mydebug('p_activity_id = ' || 1);
            wms_atf_runtime_pub_apis.init_op_plan_instance(
              x_return_status      => l_return_status
            , x_msg_data           => l_msg_data
            , x_msg_count          => l_msg_count
            , x_error_code         => l_atf_error_code
            , p_source_task_id     => l_transaction_temp_id
            , p_activity_id        => 1 -- Inbound
            );
            mydebug('suggestions_pub: After calling wms_op_runtime_pub_apis.init_plan_instance');
            mydebug('l_return_status = ' || l_return_status);

            IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('suggestions_pub: wms_op_runtime_pub_apis.init_plan_instance failed.');
              END IF;

              RAISE fnd_api.g_exc_error;
            END IF; -- (l_return_status <> fnd_api.g_ret_sts_success)
          END IF; -- (l_operation_plan_id IS NULL)
        END IF; -- ( p_drop_type IS NULL OR p_drop_type <> 'MD')

                -- End ATF_J calling operation_plan_assignment and init_op_plan_instance


                -- ATF_J
                -- By pass inserting into WMS_DISPATCHED_TASKS
                -- if customer is at patchset J or above,
                -- because this will be handled by activate_operation_instance.
                -- In other words, only insert WMS_DISPATCHED_TASKS if
                -- customer release is below patchset J

                -- We should not insert record directly into WDT if the drop type is Manual Drop.
                -- Since ATF API activate op instance will be called from complete_putaway_wrapper in this case.


        l_num_of_rows := l_num_of_rows + 1;

        --inv_debug.message('number of rows = ' || l_num_of_rows);

        IF l_transaction_quantity < 0 THEN
          UPDATE mtl_material_transactions_temp
          SET transaction_quantity = ABS(transaction_quantity)
            , primary_quantity = ABS(primary_quantity)
          WHERE  transaction_temp_id = l_transaction_temp_id;
        END IF;
      END LOOP; -- Detail loop

      CLOSE suggestions_csr;

    END LOOP; -- MO Lines loop

    CLOSE molines_csr;

    -- set output variables
    -- Get total number of rows detailed
    SELECT COUNT(t.transaction_temp_id)
    INTO   l_rows_detailed
    FROM   mtl_material_transactions_temp t, mtl_txn_request_lines l
    WHERE  l.lpn_id = l_lpn_id
    AND    l.organization_id = p_org_id
    AND    l.line_id = NVL(p_move_order_line_id, l.line_id) -- Added for ATF_J
    AND    l.line_id = t.move_order_line_id;

    x_number_of_rows := l_rows_detailed;
    x_crossdock := l_td_crossdock;
    x_return_status := fnd_api.g_ret_sts_success;

    -- Fix for Bug 2374961
    -- For an Inventory LPN, the rules engine creates a lock
    -- at the item org level as part of the detailing
    -- Since no commit was being done till the user actually confirmed
    -- the drop, the lock was being maintained for an inordinate
    -- amount of time, preventing other users from putting away
    -- the same item even if it is on a different LPn because of the
    -- fact that the rules engine cannot obtain a new lock unless
    -- the old one has been released. Hence, for an inventory LPN
    -- , have added a commit statement. If the user then changes his
    -- mind and presses F2 from the Putaway page, the
    --  cleanup_partial_putaway_LPN API is called which deletes
    -- the MMTT and MOL lines manually

    --Nested LPN Support - Do the commit only if the flag is set.
    IF (l_lpn_context = 1 AND l_rows_detailed > 0) THEN
      IF (NVL(p_commit, 'Y') = 'Y') THEN
        COMMIT;
      END IF;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      -- Bug# 2744186
      -- Perform a rollback in the exception blocks
      ROLLBACK TO suggestions_pub_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('suggestions_pub: Excecution error - ' || SQLERRM);
      END IF;

      IF pregen_suggestions_csr%ISOPEN THEN
        CLOSE pregen_suggestions_csr;
      END IF;

      IF molines_csr%ISOPEN THEN
        CLOSE molines_csr;
      END IF;

      IF lpn_csr%ISOPEN THEN
        CLOSE lpn_csr;
      END IF;

      IF suggestions_csr%ISOPEN THEN
        CLOSE suggestions_csr;
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO suggestions_pub_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('suggestions_pub: Unexpected error - ' || SQLERRM);
      END IF;

      IF pregen_suggestions_csr%ISOPEN THEN
        CLOSE pregen_suggestions_csr;
      END IF;

      IF molines_csr%ISOPEN THEN
        CLOSE molines_csr;
      END IF;

      IF lpn_csr%ISOPEN THEN
        CLOSE lpn_csr;
      END IF;

      IF suggestions_csr%ISOPEN THEN
        CLOSE suggestions_csr;
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO suggestions_pub_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('suggestions_pub: Others exception - ' || SQLERRM);
      END IF;

      IF pregen_suggestions_csr%ISOPEN THEN
        CLOSE pregen_suggestions_csr;
      END IF;

      IF molines_csr%ISOPEN THEN
        CLOSE molines_csr;
      END IF;

      IF lpn_csr%ISOPEN THEN
        CLOSE lpn_csr;
      END IF;

      IF suggestions_csr%ISOPEN THEN
        CLOSE suggestions_csr;
      END IF;
  END suggestions_pub;

  /* Local function to insert record in MTL_SERIAL_NUMBERS_TEMP given
   * a record type containing the information of one serial number (including
   * attributes). This procedure is called from complete_putaway to create
   * as many MSNT records for the serial numbers within the LPN for the quantity
   * confirmed
   */
  FUNCTION insert_msnt_rec(
    p_transaction_temp_id  IN  NUMBER
  , p_serial_number        IN  VARCHAR2
  , p_serial_atts          IN  msn_attribute_rec_tp
  , p_user_id              IN  NUMBER
  , p_to_serial_number     IN  VARCHAR2 DEFAULT NULL) RETURN BOOLEAN IS
  BEGIN
    INSERT INTO mtl_serial_numbers_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , fm_serial_number
               , to_serial_number
               , vendor_serial_number
               , vendor_lot_number
               , parent_serial_number
               , origination_date
               , end_item_unit_number
               , territory_code
               , time_since_new
               , cycles_since_new
               , time_since_overhaul
               , cycles_since_overhaul
               , time_since_repair
               , cycles_since_repair
               , time_since_visit
               , cycles_since_visit
               , time_since_mark
               , cycles_since_mark
               , number_of_repairs
               , serial_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
                )
    VALUES      (
                 p_transaction_temp_id
               , SYSDATE
               , p_user_id
               , SYSDATE
               , p_user_id
               , p_serial_number
               , Nvl(p_to_serial_number,p_serial_number)
               , p_serial_atts.vendor_serial_number
               , p_serial_atts.vendor_lot_number
               , p_serial_atts.parent_serial_number
               , p_serial_atts.origination_date
               , p_serial_atts.end_item_unit_number
               , p_serial_atts.territory_code
               , p_serial_atts.time_since_new
               , p_serial_atts.cycles_since_new
               , p_serial_atts.time_since_overhaul
               , p_serial_atts.cycles_since_overhaul
               , p_serial_atts.time_since_repair
               , p_serial_atts.cycles_since_repair
               , p_serial_atts.time_since_visit
               , p_serial_atts.cycles_since_visit
               , p_serial_atts.time_since_mark
               , p_serial_atts.cycles_since_mark
               , p_serial_atts.number_of_repairs
               , p_serial_atts.serial_attribute_category
               , p_serial_atts.c_attribute1
               , p_serial_atts.c_attribute2
               , p_serial_atts.c_attribute3
               , p_serial_atts.c_attribute4
               , p_serial_atts.c_attribute5
               , p_serial_atts.c_attribute6
               , p_serial_atts.c_attribute7
               , p_serial_atts.c_attribute8
               , p_serial_atts.c_attribute9
               , p_serial_atts.c_attribute10
               , p_serial_atts.c_attribute11
               , p_serial_atts.c_attribute12
               , p_serial_atts.c_attribute13
               , p_serial_atts.c_attribute14
               , p_serial_atts.c_attribute15
               , p_serial_atts.c_attribute16
               , p_serial_atts.c_attribute17
               , p_serial_atts.c_attribute18
               , p_serial_atts.c_attribute19
               , p_serial_atts.c_attribute20
               , p_serial_atts.d_attribute1
               , p_serial_atts.d_attribute2
               , p_serial_atts.d_attribute3
               , p_serial_atts.d_attribute4
               , p_serial_atts.d_attribute5
               , p_serial_atts.d_attribute6
               , p_serial_atts.d_attribute7
               , p_serial_atts.d_attribute8
               , p_serial_atts.d_attribute9
               , p_serial_atts.d_attribute10
               , p_serial_atts.n_attribute1
               , p_serial_atts.n_attribute2
               , p_serial_atts.n_attribute3
               , p_serial_atts.n_attribute4
               , p_serial_atts.n_attribute5
               , p_serial_atts.n_attribute6
               , p_serial_atts.n_attribute7
               , p_serial_atts.n_attribute8
               , p_serial_atts.n_attribute9
               , p_serial_atts.n_attribute10
                );
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END insert_msnt_rec;


  /* Local function to insert a record in MTL_TRANSACTION_LOTS_TEMP
   * from the original MTLT record. These MTLT records are needed by
   * the receiving transaction manager for the deliver transaction
   */
  FUNCTION insert_dup_mtlt (
        p_orig_temp_id    IN  NUMBER
      , p_new_temp_id     IN  NUMBER
      , p_serial_temp_id  IN  NUMBER
      , p_item_id         IN  NUMBER
      , p_organization_id IN  NUMBER) RETURN BOOLEAN IS
  BEGIN
    INSERT INTO mtl_transaction_lots_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , transaction_quantity
               , primary_quantity
               , lot_number
               , lot_expiration_date
               , serial_transaction_temp_id
               , description
               , vendor_name
               , supplier_lot_number
               , origination_date
               , date_code
               , grade_code
               , change_date
               , maturity_date
               , retest_date
               , age
               , item_size
               , color
               , volume
               , volume_uom
               , place_of_origin
               , best_by_date
               , LENGTH
               , length_uom
               , recycled_content
               , thickness
               , thickness_uom
               , width
               , width_uom
               , curl_wrinkle_fold
               , lot_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
               , vendor_id
               , territory_code
               , attribute_category  --Bug#7019043.Added this and following 15 columns
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
                )
      (SELECT p_new_temp_id
            , mtlt.last_update_date
            , mtlt.last_updated_by
            , mtlt.creation_date
            , mtlt.created_by
            , mtlt.transaction_quantity
            , mtlt.primary_quantity
            , mtlt.lot_number
            , mtlt.lot_expiration_date
            , p_serial_temp_id
            , mln.description
            , mln.vendor_name
            , mln.supplier_lot_number
            , mln.origination_date
            , mln.date_code
            , mln.grade_code
            , mln.change_date
            , mln.maturity_date
            , mln.retest_date
            , mln.age
            , mln.item_size
            , mln.color
            , mln.volume
            , mln.volume_uom
            , mln.place_of_origin
            , mln.best_by_date
            , mln.LENGTH
            , mln.length_uom
            , mln.recycled_content
            , mln.thickness
            , mln.thickness_uom
            , mln.width
            , mln.width_uom
            , mln.curl_wrinkle_fold
            , mln.lot_attribute_category
            , mln.c_attribute1
            , mln.c_attribute2
            , mln.c_attribute3
            , mln.c_attribute4
            , mln.c_attribute5
            , mln.c_attribute6
            , mln.c_attribute7
            , mln.c_attribute8
            , mln.c_attribute9
            , mln.c_attribute10
            , mln.c_attribute11
            , mln.c_attribute12
            , mln.c_attribute13
            , mln.c_attribute14
            , mln.c_attribute15
            , mln.c_attribute16
            , mln.c_attribute17
            , mln.c_attribute18
            , mln.c_attribute19
            , mln.c_attribute20
            , mln.d_attribute1
            , mln.d_attribute2
            , mln.d_attribute3
            , mln.d_attribute4
            , mln.d_attribute5
            , mln.d_attribute6
            , mln.d_attribute7
            , mln.d_attribute8
            , mln.d_attribute9
            , mln.d_attribute10
            , mln.n_attribute1
            , mln.n_attribute2
            , mln.n_attribute3
            , mln.n_attribute4
            , mln.n_attribute5
            , mln.n_attribute6
            , mln.n_attribute7
            , mln.n_attribute8
            , mln.n_attribute9
            , mln.n_attribute10
            , mln.vendor_id
            , mln.territory_code
            , mln.attribute_category  --Bug#7019043.Added this and the following 15 cols
            , mln.attribute1
            , mln.attribute2
            , mln.attribute3
            , mln.attribute4
            , mln.attribute5
            , mln.attribute6
            , mln.attribute7
            , mln.attribute8
            , mln.attribute9
            , mln.attribute10
            , mln.attribute11
            , mln.attribute12
            , mln.attribute13
            , mln.attribute14
            , mln.attribute15
       FROM   mtl_transaction_lots_temp mtlt
            , mtl_lot_numbers mln
       WHERE  mtlt.transaction_temp_id = p_orig_temp_id
       AND    mln.lot_number = mtlt.lot_number
       AND    mln.inventory_item_id = p_item_id
       AND    mln.organization_id = p_organization_id);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END insert_dup_mtlt;

  /* Local function to insert records in MTL_SERIAL_NUMBERS_TEMP
   * from the original MSNT record(s). These records are needed by
   * the receiving transaction manager for the deliver transaction
   */
  FUNCTION insert_dup_msnt (
        p_orig_temp_id    IN  NUMBER
      , p_new_temp_id     IN  NUMBER) RETURN BOOLEAN IS
  BEGIN
    INSERT INTO mtl_serial_numbers_temp
                (
                 transaction_temp_id
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , fm_serial_number
               , to_serial_number
               , vendor_serial_number
               , vendor_lot_number
               , parent_serial_number
               , origination_date
               , end_item_unit_number
               , territory_code
               , time_since_new
               , cycles_since_new
               , time_since_overhaul
               , cycles_since_overhaul
               , time_since_repair
               , cycles_since_repair
               , time_since_visit
               , cycles_since_visit
               , time_since_mark
               , cycles_since_mark
               , number_of_repairs
               , serial_attribute_category
               , c_attribute1
               , c_attribute2
               , c_attribute3
               , c_attribute4
               , c_attribute5
               , c_attribute6
               , c_attribute7
               , c_attribute8
               , c_attribute9
               , c_attribute10
               , c_attribute11
               , c_attribute12
               , c_attribute13
               , c_attribute14
               , c_attribute15
               , c_attribute16
               , c_attribute17
               , c_attribute18
               , c_attribute19
               , c_attribute20
               , d_attribute1
               , d_attribute2
               , d_attribute3
               , d_attribute4
               , d_attribute5
               , d_attribute6
               , d_attribute7
               , d_attribute8
               , d_attribute9
               , d_attribute10
               , n_attribute1
               , n_attribute2
               , n_attribute3
               , n_attribute4
               , n_attribute5
               , n_attribute6
               , n_attribute7
               , n_attribute8
               , n_attribute9
               , n_attribute10
                )
      (SELECT p_new_temp_id
            , last_update_date
            , last_updated_by
            , creation_date
            , created_by
            , fm_serial_number
            , to_serial_number
            , vendor_serial_number
            , vendor_lot_number
            , parent_serial_number
            , origination_date
            , end_item_unit_number
            , territory_code
            , time_since_new
            , cycles_since_new
            , time_since_overhaul
            , cycles_since_overhaul
            , time_since_repair
            , cycles_since_repair
            , time_since_visit
            , cycles_since_visit
            , time_since_mark
            , cycles_since_mark
            , number_of_repairs
            , serial_attribute_category
            , c_attribute1
            , c_attribute2
            , c_attribute3
            , c_attribute4
            , c_attribute5
            , c_attribute6
            , c_attribute7
            , c_attribute8
            , c_attribute9
            , c_attribute10
            , c_attribute11
            , c_attribute12
            , c_attribute13
            , c_attribute14
            , c_attribute15
            , c_attribute16
            , c_attribute17
            , c_attribute18
            , c_attribute19
            , c_attribute20
            , d_attribute1
            , d_attribute2
            , d_attribute3
            , d_attribute4
            , d_attribute5
            , d_attribute6
            , d_attribute7
            , d_attribute8
            , d_attribute9
            , d_attribute10
            , n_attribute1
            , n_attribute2
            , n_attribute3
            , n_attribute4
            , n_attribute5
            , n_attribute6
            , n_attribute7
            , n_attribute8
            , n_attribute9
            , n_attribute10
       FROM   mtl_serial_numbers_temp
       WHERE  transaction_temp_id = p_orig_temp_id);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END insert_dup_msnt;

  /* FP-J Lot/Serial Support Enhancement
   * Helper routine to create MTL_TRANSACTION_LOTS_INTERFACE records
   * for the lot and quantity corresponding to the drop quantity
   * Called for a receiving LPN when INV and PO patch levels are J or higher
   */
  FUNCTION insert_mtli_helper(
          p_txn_if_id       IN OUT NOCOPY NUMBER
        , p_lot_number      IN            VARCHAR2
        , p_txn_qty         IN            NUMBER
        , p_prm_qty         IN            NUMBER
        , p_item_id         IN            NUMBER
        , p_org_id          IN            NUMBER
        , x_serial_temp_id  OUT NOCOPY    NUMBER
        , p_product_txn_id  IN OUT NOCOPY NUMBER
        , p_temp_id         IN            NUMBER
        , p_secondary_quantity IN NUMBER --OPM Convergence
        , p_secondary_uom   IN VARCHAR2  --OPM Convergence /* Fix for Bug#9037915. Changed NUMBER to VARCHAR2
        ) RETURN BOOLEAN IS
    --Local variables
    l_lot_status_id         NUMBER;
    l_txn_if_id             NUMBER      :=  p_txn_if_id;
    l_product_txn_id        NUMBER      :=  p_product_txn_id;
    l_expiration_date       DATE;
    l_prod_code             VARCHAR2(5) := inv_rcv_integration_apis.G_PROD_CODE;
    l_yes                   VARCHAR2(1) := inv_rcv_integration_apis.G_YES;
    l_no                    VARCHAR2(1) := inv_rcv_integration_apis.G_NO;
    l_false                 VARCHAR2(1) := inv_rcv_integration_apis.G_FALSE;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(10000);
    l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    --Get the required columns from MLN first
    SELECT  expiration_date
          , status_id
    INTO    l_expiration_date
          , l_lot_status_id
    FROM    mtl_lot_numbers
    WHERE   lot_number = p_lot_number
    AND     inventory_item_id = p_item_id
    AND     organization_id = p_org_id;

/*
    , p_secondary_quantity         IN             NUMBER  DEFAULT NULL--OPM Convergence
    , p_origination_type           IN             NUMBER DEFAULT NULL--OPM Convergence
    , p_expiration_action_code     IN             VARCHAR2 DEFAULT NULL--OPM Convergence
    , p_expiration_action_date     IN             DATE DEFAULT NULL-- OPM Convergence
    , p_hold_date                  IN             DATE DEFAULT NULL--OPM Convergence
    , p_parent_lot_number          IN             VARCHAR2 DEFAULT NULL--OPM Convergence
    , p_reasond_id                 IN             NUMBER DEFAULT NULL--OPM convergence
    ); */
    --Call the insert_mtli API
    inv_rcv_integration_apis.insert_mtli(
          p_api_version                 =>  1.0
        , p_init_msg_lst                =>  l_false
        , x_return_status               =>  l_return_status
        , x_msg_count                   =>  l_msg_count
        , x_msg_data                    =>  l_msg_data
        , p_transaction_interface_id    =>  l_txn_if_id
        , p_lot_number                  =>  p_lot_number
        , p_transaction_quantity        =>  p_txn_qty
        , p_primary_quantity            =>  p_prm_qty
        , p_organization_id             =>  p_org_id
        , p_inventory_item_id           =>  p_item_id
        , p_expiration_date             =>  l_expiration_date
        , p_status_id                   =>  l_lot_status_id
        , x_serial_transaction_temp_id  =>  x_serial_temp_id
        , p_product_transaction_id      =>  l_product_txn_id
        , p_product_code                =>  l_prod_code
        , p_att_exist                   =>  l_yes
        , p_update_mln                  =>  l_no
        , p_secondary_quantity          =>  p_secondary_quantity --OPM Convergence
        );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
      IF (l_debug = 1) THEN
        mydebug('insert_mtli_helper: Error occurred while creating interface lots: ' || l_msg_data);
      END IF;
      RETURN FALSE;
    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Exception occurred in insert_mtli_helper: ');
      END IF;
      RETURN FALSE;
  END insert_mtli_helper;

  /* FP-J Lot/Serial Support Enhancement
   * Helper routine to create MTL_SERIAL_NUMBERS_INTERFACE records
   * for the serials corresponding to the dropped quantity
   * Called for a receiving LPN when INV and PO patch levels are J or higher
   */
  FUNCTION insert_msni_helper(
          p_txn_if_id       IN OUT NOCOPY NUMBER
        , p_serial_number   IN            VARCHAR2
        , p_item_id         IN            NUMBER
        , p_org_id          IN            NUMBER
        , p_product_txn_id  IN OUT NOCOPY NUMBER
       ) RETURN BOOLEAN IS
    --Local variables
    l_serial_status_id      NUMBER;
    l_txn_if_id             NUMBER      :=  p_txn_if_id;
    l_product_txn_id        NUMBER      :=  p_product_txn_id;
    l_prod_code             VARCHAR2(5) := inv_rcv_integration_apis.G_PROD_CODE;
    l_yes                   VARCHAR2(1) := inv_rcv_integration_apis.G_YES;
    l_no                    VARCHAR2(1) := inv_rcv_integration_apis.G_NO;
    l_false                 VARCHAR2(1) := inv_rcv_integration_apis.G_FALSE;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(10000);
    l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN

    --Get the serial status
    SELECT  status_id
    INTO    l_serial_status_id
    FROM    mtl_serial_numbers
    WHERE   serial_number = p_serial_number
    AND     inventory_item_id = p_item_id;

    --Call the insert_msni API
    inv_rcv_integration_apis.insert_msni(
          p_api_version                 =>  1.0
        , p_init_msg_lst                =>  l_false
        , x_return_status               =>  l_return_status
        , x_msg_count                   =>  l_msg_count
        , x_msg_data                    =>  l_msg_data
        , p_transaction_interface_id    =>  l_txn_if_id
        , p_fm_serial_number            =>  p_serial_number
        , p_to_serial_number            =>  p_serial_number
        , p_organization_id             =>  p_org_id
        , p_inventory_item_id           =>  p_item_id
        , p_status_id                   =>  l_serial_status_id
        , p_product_transaction_id      =>  l_product_txn_id
        , p_product_code                =>  l_prod_code
        , p_att_exist                   =>  l_yes
        , p_update_msn                  =>  l_no);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);
      IF (l_debug = 1) THEN
        mydebug('insert_msni_helper: Error occurred while creating interface serials: ' || l_msg_data);
      END IF;
      RETURN FALSE;
    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('Exception occurred in insert_msni_helper: ');
      END IF;
      RETURN FALSE;
  END insert_msni_helper;

  --3978111 CHANGES START
procedure create_snapshot(p_temp_id NUMBER, p_org_id NUMBER)
IS
    l_errNum                       NUMBER;
    l_errCode                      VARCHAR2(1);
    l_errMsg                       VARCHAR2(241);
    l_cst_ret                      NUMBER(1):=0;
    l_primary_cost_method          NUMBER;
    l_debug			   NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
BEGIN
	select primary_cost_method
	into   l_primary_cost_method
	from   mtl_parameters
	where  organization_id = p_org_id;

	IF (l_debug = 1) THEN
		mydebug('complete_putaway: cost method of org'||p_org_id||' is '||l_primary_cost_method);
	END IF;

	IF l_primary_cost_method in (2,5,6) THEN
		IF (l_debug = 1) THEN
			mydebug('complete_putaway: PRIMARY COST METHOD IS AVG OR FIFO OR LIFO CALLING CSTACOSN.op_snapshot'||p_temp_id);
		END IF;

		l_cst_ret := CSTACOSN.op_snapshot(i_txn_temp_id => p_temp_id,
						err_num => l_errNum,
						err_code => l_errCode,
						err_msg => l_errMsg);
		IF(l_cst_ret <> 1) THEN
			fnd_message.set_name('BOM', 'CST_SNAPSHOT_FAILED');
			fnd_msg_pub.ADD;
			IF (l_debug = 1) THEN
				mydebug('complete_putaway: Error from CSTACOSN.op_snapshot ');
			END IF;
			raise fnd_api.g_exc_unexpected_error;
		ELSE
			mydebug('complete_putaway: CALL TO CSTACOSN.op_snapshot SUCCESSFULL');
		END IF;

	END IF;
END create_snapshot;
--3978111 CHANGES END

  -- Bug# 2795096
  -- Added an extra input parameter called p_commit
  -- which will default to 'Y' = Yes.
  -- This is needed when we are performing a consolidated drop
  -- where complete_putaway is called for each and every MMTT line
  -- within the same commit cycle.  Previously it would perform a
  -- commit at the end of the call to complete_putaway.  This doesn't
  -- work for consolidated drops since if one of the MMTT lines fails
  -- in the call to complete_putaway, we'd like to rollback all of the
  -- changes done.  Thus we should not call a commit until complete_putaway
  -- has been successfully called for every MMTT line.

  -- FP-J Lot/Serial Support Enhancement
  -- Added a new parameter p_product_transaction_id which stores
  -- the product_transaction_id column value in MTLI/MSNI for lots and serials
  -- that were created from the putaway drop UI. This value would be populated
  -- only if there were a quantity discrepancy in the UI

  -- Nested LPN support
  -- Added new parameter p_lpn_mode,
  -- This will have the following 3 values
  --    1 - Tranfer all contents, including child LPNs
  --    2 - Drop into To another LPN
  --    3 - Item based drop

  PROCEDURE complete_putaway(
    p_lpn_id                  IN             NUMBER
  , p_org_id                  IN             NUMBER
  , p_temp_id                 IN             NUMBER
  , p_item_id                 IN             NUMBER
  , p_rev                     IN             VARCHAR2
  , p_lot                     IN             VARCHAR2
  , p_loc                     IN             NUMBER
  , p_sub                     IN             VARCHAR2
  , p_qty                     IN             NUMBER
  , p_uom                     IN             VARCHAR2
  , p_user_id                 IN             NUMBER
  , p_disc                    IN             VARCHAR2
  , x_return_status           OUT NOCOPY     VARCHAR2
  , x_msg_count               OUT NOCOPY     NUMBER
  , x_msg_data                OUT NOCOPY     VARCHAR2
  , p_entire_lpn              IN             VARCHAR2 := 'N'
  , p_to_lpn                  IN             VARCHAR2 := fnd_api.g_miss_char
  , p_qty_reason_id           IN             NUMBER
  , p_loc_reason_id           IN             NUMBER
  , p_process_serial_flag     IN             VARCHAR2
  , p_commit                  IN             VARCHAR2 := 'Y'
  , p_product_transaction_id  IN             NUMBER
  , p_lpn_mode                IN             NUMBER
  , p_new_txn_header_id       IN             NUMBER
  , p_secondary_quantity      IN             NUMBER --OPM Convergence
  , p_secondary_uom           IN             VARCHAR2 --OPM Convergence
  , p_primary_uom             IN             VARCHAR2
    ) IS
    l_exist_lpn                  NUMBER;
    l_ref                        VARCHAR2(240);
    l_ref_id                     NUMBER;
    l_ref_type                   NUMBER;
    l_qty                        NUMBER;
    l_lot_code                   NUMBER;
    l_serial_code                NUMBER;
    l_is_msni_req                NUMBER        :=0;
    l_pr_qty                     NUMBER;
    l_serial                     VARCHAR2(30);
    l_ser_seq                    NUMBER;
    l_org_sub                    VARCHAR2(30);
    l_org_loc                    NUMBER;
    l_lpn_context                NUMBER;
    l_txn_ret                    NUMBER        := 0;
    l_orig_qty                   NUMBER;
    l_txn_header_id              NUMBER;
    l_orig_txn_header_id         NUMBER;
    l_to_lpn_id                  NUMBER;
    l_txn_mode                   NUMBER        := 2;
    l_del_detail_id              NUMBER;
    l_orig_txn_uom               VARCHAR2(3);
    l_dest_loc_id                NUMBER;
    l_dest_sub                   VARCHAR2(10);
    l_txn_action_id              NUMBER;
    l_dup_temp_id                NUMBER;
    l_dup_ser_temp_id            NUMBER;
    l_dup_ser_temp_id_exist      NUMBER;
    l_lpn_sub                    VARCHAR2(30);
    l_lpn_loc                    NUMBER;
    l_flow_code                  NUMBER;
    l_transaction_source_type_id NUMBER        := 0;
    l_inspection_status          NUMBER        := 1;
    l_mo_lpn_id                  NUMBER        := 0;
    l_wf                         NUMBER;
    l_wf_process                 VARCHAR2(80);
    l_task_id                    NUMBER;
    l_wip_supply_type            NUMBER        := NULL;
    l_crossdock_type             NUMBER        := NULL;
    cnt                          NUMBER        := NULL;
    l_business_flow_code         NUMBER        := 30; -- default to Inventory Putaway
    l_wf_temp_sub                VARCHAR2(255);
    l_wf_temp_loc                NUMBER;
    -- following variables added for ATF_J3

    l_atf_error_code               NUMBER;
    l_op_plan_instance_status      NUMBER;
    l_return_status                VARCHAR2(1);
    l_msg_data                     VARCHAR2(2000);
    l_msg_count                    NUMBER;
    l_move_order_line_id           NUMBER;
    l_mmtt_transaction_qty         NUMBER;
    l_serial_transaction_temp_id   NUMBER;
    l_txn_type_id		   NUMBER;--Added bug 3978111
    -- End variables added for ATF_J3

    l_secondary_uom_code  mtl_material_transactions_temp.secondary_uom_code%TYPE;
    l_secondary_qty NUMBER;

    l_exist_msnt                   NUMBER:=0 ;--Added for bug 5213359

    l_acct_period_id               NUMBER:=0; --Added for bug 5403420
    l_open_past_period		   BOOLEAN; --Added for bug 5403420

    -- Added for Bug 6356147
    l_flow_schedule                VARCHAR2(1);

    --Bug #2966531 - Fetch serial attributes in addition to serial number
    --from MTL_SERIAL_NUMBERS for the LPN item combination
    CURSOR ser_csr IS
      SELECT serial_number
	   , serial_number to_serial_number
           , vendor_serial_number
           , vendor_lot_number
           , parent_serial_number
           , origination_date
           , end_item_unit_number
           , territory_code
           , time_since_new
           , cycles_since_new
           , time_since_overhaul
           , cycles_since_overhaul
           , time_since_repair
           , cycles_since_repair
           , time_since_visit
           , cycles_since_visit
           , time_since_mark
           , cycles_since_mark
           , number_of_repairs
           , serial_attribute_category
           , c_attribute1
           , c_attribute2
           , c_attribute3
           , c_attribute4
           , c_attribute5
           , c_attribute6
           , c_attribute7
           , c_attribute8
           , c_attribute9
           , c_attribute10
           , c_attribute11
           , c_attribute12
           , c_attribute13
           , c_attribute14
           , c_attribute15
           , c_attribute16
           , c_attribute17
           , c_attribute18
           , c_attribute19
          , c_attribute20
           , d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
           , n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
      FROM   mtl_serial_numbers
      WHERE  lpn_id = p_lpn_id
      AND    inventory_item_id = p_item_id
      AND    NVL(revision, '#%^') = NVL(p_rev, '#%^')
      AND    NVL(lot_number, -999) = NVL(p_lot, -999)
      AND    ROWNUM <= l_pr_qty
      AND    (
              (p_entire_lpn = 'Y'
               AND(group_mark_id IS NULL
                   OR group_mark_id = -1))
              OR(p_entire_lpn = 'N'
                AND group_mark_id = 1)
              OR(p_process_serial_flag = 'N'
                 AND p_entire_lpn = 'N'
                 AND group_mark_id IS NULL)
             )
      -- Bug# 2772676
      -- For WIP completions, there is a specific serial
      -- tied to the MOL/MMTT line which we have to use
      AND    (
              (l_transaction_source_type_id = 5
               AND serial_number IN(SELECT fm_serial_number
                                    FROM   wip_lpn_completions_serials
                                    WHERE  header_id = l_ref_id))
              OR l_transaction_source_type_id <> 5
             );

    transfer_lpn_id       NUMBER;
    content_lpn_id        NUMBER;
    lpn_id                NUMBER;
    temp_count            NUMBER;
    l_emp_id              NUMBER;
    l_debug               NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    -- ER 7307189 changes start

    res_count       NUMBER :=0;


     CURSOR ser_csr_reserved_lpn
                IS
                        SELECT  serial_number                  ,
                                serial_number to_serial_number ,
                                vendor_serial_number           ,
                                vendor_lot_number              ,
                                parent_serial_number           ,
                                origination_date               ,
                                end_item_unit_number           ,
                                territory_code                 ,
                                time_since_new                 ,
                                cycles_since_new               ,
                                time_since_overhaul            ,
                                cycles_since_overhaul          ,
                                time_since_repair              ,
                                cycles_since_repair            ,
                                time_since_visit               ,
                                cycles_since_visit             ,
                                time_since_mark                ,
                                cycles_since_mark              ,
                                number_of_repairs              ,
                                serial_attribute_category      ,
                                c_attribute1                   ,
                                c_attribute2                   ,
                                c_attribute3                   ,
                                c_attribute4                   ,
                                c_attribute5                   ,
                                c_attribute6                   ,
                                c_attribute7                   ,
                                c_attribute8                   ,
                                c_attribute9                   ,
                                c_attribute10                  ,
                                c_attribute11                  ,
                                c_attribute12                  ,
                                c_attribute13                  ,
                                c_attribute14                  ,
                                c_attribute15                  ,
                                c_attribute16                  ,
                                c_attribute17                  ,
                                c_attribute18                  ,
                                c_attribute19                  ,
                                c_attribute20                  ,
                                d_attribute1                   ,
                                d_attribute2                   ,
                                d_attribute3                   ,
                                d_attribute4                   ,
                                d_attribute5                   ,
                                d_attribute6                   ,
                                d_attribute7                   ,
                                d_attribute8                   ,
                                d_attribute9                   ,
                                d_attribute10                  ,
                                n_attribute1                   ,
                                n_attribute2                   ,
                                n_attribute3                   ,
                                n_attribute4                   ,
                                n_attribute5                   ,
                                n_attribute6                   ,
                                n_attribute7                   ,
                                n_attribute8                   ,
                                n_attribute9                   ,
                                n_attribute10
                        FROM    mtl_serial_numbers
                        WHERE   lpn_id                = p_lpn_id
                            AND inventory_item_id     = p_item_id
                            AND NVL(revision, '#%^')  = NVL(p_rev, '#%^')
                            AND NVL(lot_number, -999) = NVL(p_lot, -999)
                            AND ROWNUM               <= l_pr_qty
                            AND
                                (
                                        (
                                            p_entire_lpn = 'Y'
                                            AND
                                                (
                                                        group_mark_id IS NULL
                                                     OR group_mark_id >= -1
                                                )
                                        )
                                     OR
                                        (
                                            p_entire_lpn  = 'N'
                                            AND group_mark_id = 1
                                        )
                                     OR
                                        (
                                            p_process_serial_flag = 'N'
                                            AND p_entire_lpn          = 'N'
                                            AND group_mark_id IS NULL
                                        )
                                )
                                -- Bug# 2772676
                                -- For WIP completions, there is a specific serial
                                -- tied to the MOL/MMTT line which we have to use
                            AND
                                (
                                        (
                                            l_transaction_source_type_id = 5
                                            AND serial_number               IN
                                                (
                                                        SELECT  fm_serial_number
                                                        FROM    wip_lpn_completions_serials
                                                        WHERE   header_id = l_ref_id
                                                )
                                        )
                                     OR l_transaction_source_type_id <> 5
                                );
    -- ER 7307189 changes end


    --Cursors and Variables for FP-J Lot/Serial Support enhancement
    CURSOR c_rcv_ser_csr IS
      SELECT serial_number
	   , serial_number to_serial_number
           , vendor_serial_number
           , vendor_lot_number
           , parent_serial_number
           , origination_date
           , end_item_unit_number
           , territory_code
           , time_since_new
           , cycles_since_new
           , time_since_overhaul
           , cycles_since_overhaul
           , time_since_repair
           , cycles_since_repair
           , time_since_visit
           , cycles_since_visit
           , time_since_mark
           , cycles_since_mark
           , number_of_repairs
           , serial_attribute_category
           , c_attribute1
           , c_attribute2
           , c_attribute3
           , c_attribute4
           , c_attribute5
           , c_attribute6
           , c_attribute7
           , c_attribute8
           , c_attribute9
           , c_attribute10
           , c_attribute11
           , c_attribute12
           , c_attribute13
           , c_attribute14
           , c_attribute15
           , c_attribute16
           , c_attribute17
           , c_attribute18
           , c_attribute19
           , c_attribute20
           , d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
           , n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
	FROM   mtl_serial_numbers msn
      WHERE  msn.lpn_id = p_lpn_id
      AND    msn.inventory_item_id = p_item_id
      AND    ((p_rev IS NOT NULL AND msn.revision = p_rev)
              OR (p_rev IS NULL AND msn.revision IS NULL))
      AND    ((p_lot IS NOT NULL AND msn.lot_number = p_lot)
              OR (p_lot IS NULL AND msn.lot_number IS NULL))
      AND    ROWNUM <= l_pr_qty
      AND    (
              (p_entire_lpn = 'Y'
               AND(msn.group_mark_id IS NULL OR msn.group_mark_id = -1)
              )
              OR(p_entire_lpn = 'N' AND group_mark_id = 1)
              OR(p_process_serial_flag = 'N'
                 AND p_entire_lpn = 'N'
                 AND group_mark_id IS NULL)
	      )
     ORDER BY msn.lot_number, msn.serial_number;

     --Cursors and Variables for FP-J Lot/Serial Support enhancement
     CURSOR c_msni_ser_csr(v_prod_txn_id NUMBER) IS
      SELECT fm_serial_number serial_number
	   , to_serial_number to_serial_number
           , vendor_serial_number
           , vendor_lot_number
           , parent_serial_number
           , origination_date
           , NULL end_item_unit_number
           , territory_code
           , time_since_new
           , cycles_since_new
           , time_since_overhaul
           , cycles_since_overhaul
           , time_since_repair
           , cycles_since_repair
           , time_since_visit
           , cycles_since_visit
           , time_since_mark
           , cycles_since_mark
           , number_of_repairs
           , serial_attribute_category
           , c_attribute1
           , c_attribute2
           , c_attribute3
           , c_attribute4
           , c_attribute5
           , c_attribute6
           , c_attribute7
           , c_attribute8
           , c_attribute9
           , c_attribute10
           , c_attribute11
           , c_attribute12
           , c_attribute13
           , c_attribute14
           , c_attribute15
           , c_attribute16
           , c_attribute17
           , c_attribute18
           , c_attribute19
           , c_attribute20
           , d_attribute1
           , d_attribute2
           , d_attribute3
           , d_attribute4
           , d_attribute5
           , d_attribute6
           , d_attribute7
           , d_attribute8
           , d_attribute9
           , d_attribute10
           , n_attribute1
           , n_attribute2
           , n_attribute3
           , n_attribute4
           , n_attribute5
           , n_attribute6
           , n_attribute7
           , n_attribute8
           , n_attribute9
           , n_attribute10
	FROM mtl_serial_numbers_interface msni
	-- Bug# 3281512 - Performance Fixes
	-- Since this cursor is only used for receiving, the product code
	-- will always be 'RCV'.  This is needed in order to use the index.
	WHERE msni.product_code = 'RCV'
	AND msni.product_transaction_id = v_prod_txn_id;

    l_parent_txn_id           NUMBER;
    l_mol_lot_number          mtl_lot_numbers.lot_number%TYPE;
    l_result                  BOOLEAN := TRUE;
    l_serial_rec              msn_attribute_rec_tp;
    l_operation_plan_id       NUMBER;
    l_ser_mismatch_count      NUMBER;
    l_msnt_temp_id            NUMBER;
    l_product_transaction_id  NUMBER;
    l_drop_sub_type           NUMBER;
    l_mo_line_id              NUMBER;
    l_is_crossdocked          BOOLEAN := FALSE;
    l_fm_serial               VARCHAR2(30);
    l_to_serial               VARCHAR2(30);

    l_cost_group_id           NUMBER; -- BUG 4134432
    l_mmtt_id                 NUMBER; -- for DBI wms_exception and wdth link fix in J
    l_process_flag            VARCHAR2(5); -- nsinghi. Added for GME-WMS Integration
    l_xdock_tasks_exists      VARCHAR2(1) := 'N';  --9695544
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('complete_putaway: in complete putaway');
    END IF;

    /*nsinghi GME-WMS Integration Start. Determine if Process Org*/

    SELECT NVL(process_enabled_flag, 'N') INTO l_process_flag
    FROM mtl_parameters WHERE organization_id = p_org_id;

    /*nsinghi GME-WMS Integration End. Determine if Process Org*/

    -- Bug# 2744170
    -- Set the savepoint
    SAVEPOINT complete_putaway_sp;
    l_qty := p_qty;
    x_return_status := fnd_api.g_ret_sts_success;

    IF l_to_lpn_id = 0 THEN
      l_to_lpn_id := NULL;
    END IF;


    IF (l_debug = 1) THEN
      mydebug('complete_putaway: complete_putaway API 30');
    END IF;

    SELECT task_id
    INTO   l_task_id
    FROM   wms_dispatched_tasks
    WHERE  transaction_temp_id = p_temp_id
    AND    ROWNUM < 2;             -- prevent exception
                       --Bug 2127361 fix

    IF (l_debug = 1) THEN
      mydebug('complete_putaway: complete_putaway API');
    END IF;

    SELECT mol.REFERENCE
         , mol.reference_type_code
         , mol.reference_id
         , mol.backorder_delivery_detail_id
         , mmtt.subinventory_code
         , mmtt.locator_id
         , mmtt.transaction_action_id
         , mmtt.transfer_subinventory
         , mmtt.transfer_to_location
         , mmtt.transaction_header_id
         , mol.transaction_source_type_id
         , mol.inspection_status
         , mol.lpn_id
         , mmtt.transaction_uom
         , mmtt.transaction_quantity
         , mmtt.wip_supply_type
         , mol.crossdock_type
         , mol.txn_source_id
         , mol.lot_number
         , mol.line_id
         , mmtt.operation_plan_id
         , mmtt.transaction_type_id
         , mmtt.secondary_transaction_quantity --OPM Convergence
         , mol.to_cost_group_id --BUG 4134432
         , mmtt.secondary_uom_code  --OPM Convergence

    INTO   l_ref
         , l_ref_type
         , l_ref_id
         , l_del_detail_id
         , l_org_sub
         , l_org_loc
         , l_txn_action_id
         , l_dest_sub
         , l_dest_loc_id
         , l_orig_txn_header_id
         , l_transaction_source_type_id
         , l_inspection_status
         , l_mo_lpn_id
         , l_orig_txn_uom
         , l_orig_qty
         , l_wip_supply_type
         , l_crossdock_type
         , l_parent_txn_id
         , l_mol_lot_number
         , l_mo_line_id
         , l_operation_plan_id
         , l_txn_type_id
         , l_secondary_qty --OPM Convergence

         , l_cost_group_id -- BUG 4134432
         , l_secondary_uom_code --OPM Convergence

    FROM   mtl_txn_request_lines mol
         , mtl_material_transactions_temp mmtt
    WHERE  mmtt.transaction_temp_id = p_temp_id
    AND    mmtt.move_order_line_id = mol.line_id;

    IF (l_debug = 1) THEN
      mydebug('complete_putaway: complete_putaway API 40');
      mydebug('l_org_sub ' || l_org_sub || ' l_org_loc ' || l_org_loc);
      mydebug('p_sub ' || p_sub || ' p_loc ' || p_loc);
      mydebug('l_DEST_sub ' || l_dest_sub || ' l_dest_loc ' || l_dest_loc_id);
      mydebug('l_crossdock_type : ' || l_crossdock_type);
      mydebug('l_transaction_source_type_id: ' || l_transaction_source_type_id);
      mydebug('l_del_detail_id: ' || l_del_detail_id);
      mydebug('l_wip_supply_type: ' || l_wip_supply_type);
      mydebug('l_parent_txn_id: ' || l_parent_txn_id);
      mydebug('l_mol_lot_number: ' || l_mol_lot_number);
      mydebug('l_operation_plan_id: ' || l_operation_plan_id);
      mydebug('l_secondary_qty ' || l_secondary_qty);
      mydebug('l_secondary_uom_code ' || l_secondary_uom_code);
    END IF;

    -- Bug# 2672785: Populate the emp id instead of user id while logging an exception
    -- Bug# 2750060: Catch for no data found exception
    BEGIN
      SELECT employee_id
      INTO   l_emp_id
      FROM   fnd_user
      WHERE  user_id = p_user_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('complete_putaway: There is no employee tied to the user');
        END IF;
        l_emp_id := NULL;
    END;

       /* FP-J Lot/Serial Support Enhancement
     * Moved this SQL upward because based on the LPN context, we need
     * to open a new cursor for a receiving LPN if INV and PO patch levels
     * are J or higher
     */
    -- Check to see if its a receipt LPN
    SELECT lpn_context
    INTO   l_lpn_context
    FROM   wms_license_plate_numbers
    WHERE  lpn_id = p_lpn_id;

    IF l_lpn_context = 3 THEN
       IF (l_debug =1) THEN
	  mydebug('RCV LPN: Always generate new txn header id');
       END IF;

       SELECT mtl_material_transactions_s.NEXTVAL
	 INTO   l_txn_header_id
	 FROM   DUAL;
     ELSE
       IF (l_debug =1) THEN
	  mydebug('NON RCV LPN. p_new_txn_header_id: '||p_new_txn_header_id);
       END IF;

       -- IN case of Resides in Inventroy LPNs use the txn header id generated in wrapper
       l_txn_header_id := p_new_txn_header_id;
    END IF;

    -- ATF_J3
    -- Before J, Customer used entering 0 quantity as a workaround to skip a task
    -- because they could not specify which item to putaway prior to
    -- patchset J.
    -- In patchset J, with item based putaway, user should not need to
    -- enter 0 quantity to skip a task.

    IF l_qty <= 0 THEN
      IF (l_debug = 1) THEN
        mydebug('complete_putaway: user confirmed 0 qty.');
      END IF;

      IF (l_debug = 1) THEN
	 mydebug('complete_putaway: Current release is above J. Disallow 0 quantity.');
      END IF;
      fnd_message.set_name('INV', 'INV_QTY_MUST_EXCEED_ZERO');
      fnd_msg_pub.ADD;

      RAISE fnd_api.g_exc_error;
    END IF; --IF l_qty <= 0 THEN

    IF (l_debug = 1) THEN
      mydebug('complete_putaway: complete_putaway API 60');
    END IF;

    -- Check to see if UOM has been changed. If yes, update MMTT
    IF p_uom <> l_orig_txn_uom
       AND l_orig_qty = l_qty THEN
      IF (l_debug = 1) THEN
        mydebug('complete_putaway: Uom has changed - need to update MMTT');
        mydebug('complete_putaway: complete_putaway API 70');
      END IF;

      l_qty := inv_convert.inv_um_convert(
          item_id           => p_item_id
        , PRECISION         => NULL
        , from_quantity     => l_qty
        , from_unit         => p_uom
        , to_unit           => l_orig_txn_uom
        , from_name         => NULL
        , to_name           => NULL
        );

      UPDATE mtl_material_transactions_temp
      SET transaction_uom = p_uom
        , transaction_quantity = l_qty
      WHERE  transaction_temp_id = p_temp_id;
    END IF;

    -- Update loc and zone info, if different
    IF l_txn_action_id = 2 THEN
      -- Subtransfer , putaway of lpn already in inv
      l_lpn_sub := l_dest_sub;
      l_lpn_loc := l_dest_loc_id;

      IF (p_loc <> l_dest_loc_id)
         OR(p_sub <> l_dest_sub) THEN
        IF (l_debug = 1) THEN
          mydebug('complete_putaway: Updating transfer sub  and loc');
        END IF;

        UPDATE  mtl_material_transactions_temp
        SET     transfer_subinventory = p_sub
              , transfer_to_location = p_loc
        WHERE  transaction_temp_id = p_temp_id;
      END IF;
    ELSE
      -- Normal Putaway
      l_lpn_sub := l_org_sub;
      l_lpn_loc := l_org_loc;

      IF (p_loc <> l_org_loc)
         OR(p_sub <> l_org_sub) THEN
        IF (l_debug = 1) THEN
          mydebug('complete_putaway: Updating sub and loc');
        END IF;

        IF l_lpn_context = 3 THEN

          IF (l_debug = 1) THEN
            mydebug('complete_putaway: RCV LPN, No updates of sub and loc for receving lpn');
          END IF;
        ELSE

          UPDATE mtl_material_transactions_temp
          SET subinventory_code = p_sub
            , locator_id = p_loc
          WHERE  transaction_temp_id = p_temp_id;
        END IF; -- END IF l_lpn_context = 3 THEN
      END IF;   --END IF check txn action
    END IF;   --END IF check sub/loc discrepancy

    -- Check to see if to lpn exists. if not, create it
    IF p_to_lpn = fnd_api.g_miss_char
       OR p_to_lpn IS NULL
       OR p_to_lpn = '' THEN
      l_to_lpn_id := NULL;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('complete_putaway: To LPN was passed');
      END IF;

      l_exist_lpn := 0;

      BEGIN
        SELECT 1
        INTO   l_exist_lpn
        FROM   DUAL
        WHERE  EXISTS(SELECT 1
                      FROM   wms_license_plate_numbers
                      WHERE  license_plate_number = p_to_lpn
                      AND    organization_id = p_org_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_exist_lpn := 0;
      END;

      IF (l_exist_lpn = 0) THEN
        -- LPN does not exist, create it
        -- Call Suresh's Create LPN API
        wms_container_pub.create_lpn(
          p_api_version           => 1.0
        , p_init_msg_list         => fnd_api.g_false
        , p_commit                => fnd_api.g_false
        , x_return_status         => x_return_status
        , x_msg_count             => x_msg_count
        , x_msg_data              => x_msg_data
        , p_lpn                   => p_to_lpn
        , p_organization_id       => p_org_id
        , p_container_item_id     => NULL
        , p_lot_number            => NULL
        , p_revision              => NULL
        , p_serial_number         => NULL
        , p_subinventory          => l_lpn_sub
        , p_locator_id            => l_lpn_loc
        , p_source                => 1
        , p_cost_group_id         => NULL
        , x_lpn_id                => l_to_lpn_id
        );
        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

        IF (x_msg_count = 0) THEN
          IF (l_debug = 1) THEN
            mydebug('complete_putaway: Successful');
          END IF;
        ELSIF(x_msg_count = 1) THEN
          IF (l_debug = 1) THEN
            mydebug('complete_putaway: Not Successful');
            mydebug('complete_putaway: ' || REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            mydebug('complete_putaway: Not Successful2');
          END IF;

          FOR i IN 1 .. x_msg_count LOOP
            x_msg_data := fnd_msg_pub.get(i, 'F');

            IF (l_debug = 1) THEN
              mydebug('complete_putaway: ' || REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
            END IF;
          END LOOP;
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        -- LPN exists. Get LPN ID
        SELECT lpn_id
        INTO   l_to_lpn_id
        FROM   wms_license_plate_numbers
        WHERE  license_plate_number = p_to_lpn
        AND    organization_id = p_org_id;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('complete_putaway: After LPN creation');
    END IF;

    SELECT lot_control_code
         , serial_number_control_code
    INTO   l_lot_code
         , l_serial_code
    FROM   mtl_system_items
    WHERE  organization_id = p_org_id
    AND    inventory_item_id = p_item_id;


    -- Bug 3405320
    -- If serial_code  is 6 then check if serials exists for that item
    -- inside the LPN
    --4049874
    IF l_serial_code = 6 THEN
       SELECT count(1)
	 INTO   l_is_msni_req
	 FROM   mtl_serial_numbers
	 WHERE  inventory_item_id = p_item_id
	 AND    lpn_id = p_lpn_id
	 AND    current_status = 7
	 AND    current_organization_id = p_org_id;
    END IF;

    --If the line is crossdocked to a sales order or WIP job, set the flag
    IF (l_del_detail_id IS NOT NULL) THEN
      l_is_crossdocked := TRUE;
    ELSE
      l_is_crossdocked := FALSE;
    END IF;

    -- Do Lot and serial stuff only if there was no discrepancy
    IF (p_disc = 'N') THEN
      -- Calculate Primary Quantity
      l_pr_qty := wms_task_dispatch_gen.get_primary_quantity(
              p_item_id         => p_item_id
            , p_organization_id => p_org_id
            , p_from_quantity   => l_orig_qty
            , p_from_unit       => l_orig_txn_uom); --Bug 5225012. Passing correct UOM
                                                    --Earlier p_uom was being passed.

      IF (l_debug = 1) THEN
        mydebug('complete_putaway: primary qty: ' || l_pr_qty);
      END IF;

      IF l_lot_code > 1 THEN
        IF (l_debug = 1) THEN
          mydebug('complete_putaway: Inserting Lots');
        END IF;

        l_ser_seq := NULL;

        -- Bug 2458540
        -- IF l_serial_code>1 AND l_serial_code<>6  THEN
        --4049874
        IF ((l_serial_code > 1 AND l_serial_code <> 6)
            OR(l_serial_code = 6 AND
                                    (l_ref = 'ORDER_LINE_ID'
                                     OR l_ref = 'SHIPMENT_LINE_ID'
                                    )
              )
            ) THEN
         /* bug12607020 */
	   -- Need to get the next value for serial temp id
	   IF (l_lpn_context in (1,2)) THEN
	      select serial_transaction_temp_id  INTO  l_ser_seq FROM mtl_transaction_lots_temp
		WHERE  transaction_temp_id = p_temp_id
		AND    lot_number = p_lot;
	   END IF;
	  -- Need to get the next value for serial temp id
	   IF l_ser_seq IS NULL THEN
	   SELECT mtl_material_transactions_s.NEXTVAL
	     INTO   l_ser_seq
	     FROM   DUAL;
	   END IF;
	    /* bug12607020 */

          IF (l_debug = 1) THEN
            mydebug('complete_putaway: Lot and serial controlled item: ' || l_ser_seq);
          END IF;
        END IF;

        /* FP-J Lot/Serial Support Enhancement
         * Do not update MTL_TRANSACTION_LOTS_TEMP  from here if the LPN Resides in
         * Receiving and WMS and PO patch levels are J or higher
         * For other LPN contexts and if patch levels are lower than J,
         * continue with the updates
         */
        IF (l_lpn_context = 3) THEN
          IF (l_is_crossdocked = FALSE) THEN
            IF l_debug = 1 THEN
              mydebug('complete_putaway: LPN Resides in Receiving. No updates to MTLT from here.');
            END IF;
          ELSE
            UPDATE mtl_transaction_lots_temp
            SET    serial_transaction_temp_id = l_ser_seq
                 , last_update_date = SYSDATE
                 , last_updated_by = p_user_id
            WHERE  transaction_temp_id = p_temp_id
            AND    lot_number = p_lot;
          END IF;

	--INV/WIP LPN
        ELSE
          IF l_debug = 1 THEN
            mydebug('complete_putaway: INV/WIP LPN. Update MTLT.');
          END IF;

          UPDATE mtl_transaction_lots_temp
          SET transaction_quantity = l_orig_qty
            , primary_quantity = l_pr_qty
            , serial_transaction_temp_id = l_ser_seq
            , last_update_date = SYSDATE
            , last_updated_by = p_user_id
          WHERE  transaction_temp_id = p_temp_id
          AND    lot_number = p_lot;
        END IF;

        -- Capture lot info for WIP transactions

        /* nsinghi - GME-WMS Integration. Added additional check for l_process_flag.
        Update Lot attrs from wip_lpn_completions_lots table only for discrete orgs. */

        IF (l_transaction_source_type_id = 5 AND l_process_flag = 'N') THEN
          IF (l_debug = 1) THEN
            mydebug('complete_putaway: Capture lot atts from wip tables');
            mydebug('p_ref_id: ==> ' || l_ref_id);
            mydebug('p_temp_id: => ' || p_temp_id);
            mydebug('p_lot: =====> ' || p_lot);
          END IF;

          wms_wip_integration.capture_lot_atts(
              p_ref_id  =>  l_ref_id,
              p_temp_id =>  p_temp_id,
              p_lot     =>  p_lot);

	 --Start Bug 6356147
	 -- Update MMTT for WIP flow completions
          SELECT DECODE(wip_entity_type, 4, 'Y', 'N')
          INTO l_flow_schedule
          FROM   wip_lpn_completions
          WHERE  header_id = l_ref_id;

	 IF (l_debug = 1) THEN
            mydebug('l_flow_schedule  => ' || l_flow_schedule);
          END IF;

	  UPDATE mtl_material_transactions_temp
          SET flow_schedule = l_flow_schedule
          WHERE  transaction_temp_id = p_temp_id;
	  --End Bug 6356147
        ELSE
	   /*
           * If the item is lot controlled, we do not need temp records for
           * processing but the interface records MTLI. So we can create the
           * MTLI record here for this quantity
           */
          IF (l_lpn_context = 3) THEN

            IF l_product_transaction_id IS NULL THEN
              SELECT  rcv_transactions_interface_s.NEXTVAL
              INTO    l_product_transaction_id
              FROM    sys.dual;
            END IF;

            l_result := TRUE;

            --Call the helper routine to create the MTLI record
            l_result := insert_mtli_helper(
                  p_txn_if_id       =>  l_dup_temp_id
                , p_lot_number      =>  p_lot
                , p_txn_qty         =>  p_qty --Bug 5225012. Earlier l_orig_qty was being passed
                , p_prm_qty         =>  l_pr_qty
                , p_item_id         =>  p_item_id
                , p_org_id          =>  p_org_id
                , x_serial_temp_id  =>  l_dup_ser_temp_id
                , p_product_txn_id  =>  l_product_transaction_id
                , p_temp_id         =>  p_temp_id
                , p_secondary_quantity => p_secondary_quantity --OPM Convergence
                , p_secondary_uom   =>  p_secondary_uom);   --OPM Convergence
            IF NOT l_result THEN
              IF (l_debug = 1) THEN
              mydebug('complete_putaway: Failure while Inserting MSNI records - lot and serial controlled item');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
            END IF;   --END IF check l_result

            IF (l_debug = 1) THEN
              mydebug('complete_putaway: Inserted MTLI for lot and serial item. intf_txn_id: ' || l_dup_temp_id ||
                ', ser_temp_id : ' || l_dup_ser_temp_id || ' , prod_txn_id: ' || l_product_transaction_id);
            END IF;
          END IF;   --END IF (l_lpn_context = 3) THEN
        END IF;   --END IF l_transaction_source_type_id = 5

        IF (l_debug = 1) THEN
          mydebug('complete_putaway: SNCODE:' || l_serial_code);
        END IF;

        -- Bug 2458540
        -- IF l_serial_code>1 AND l_serial_code<>6  THEN
        --4049874 : removed the l_wms_po_j_or_higher check
        IF ((l_serial_code > 1  AND l_serial_code <> 6)
            OR (l_serial_code = 6 AND l_ref = 'ORDER_LINE_ID')
            OR (l_serial_code = 6 AND  l_ref = 'SHIPMENT_LINE_ID'
                AND l_is_msni_req > 0
              )
           ) THEN
          IF (l_debug = 1) THEN
            mydebug('complete_putaway: Inserting Serials');
          END IF;

	  -- ER 7307189 changes start

		SELECT  COUNT(msn.group_mark_id)
		INTO    res_count
		FROM    mtl_serial_numbers msn ,
			mtl_reservations mr
		WHERE   mr.lpn_id        =msn.lpn_id
		    AND msn.group_mark_id=mr.reservation_id
		    AND msn.lpn_id       = p_lpn_id;

		mydebug(' complete_putaway : res_count value ' || res_count);

	   -- ER 7307189 changes end
          /*
           * If the MOL LPN context is "RESIDES IN RECEIVING" and INV and PO Patch
           * levels are J or higher, then open the cursor c_rcv_ser_csr that
           * fetches the serial by matches the serials in rcv_serials_supply for
           * the parent transaction.
           * If either of these is not true, then open the original cursor
           */
          IF (l_lpn_context = 3) THEN
            OPEN c_rcv_ser_csr;
          ELSE
	        -- ER 7307189 changes start
		IF ( res_count > 0 ) THEN
			OPEN ser_csr_reserved_lpn;
		ELSE
			OPEN ser_csr;
		END IF;
		-- ER 7307189 changes end
          END IF;

          LOOP
	    IF (l_lpn_context = 3) THEN
              FETCH c_rcv_ser_csr INTO l_serial_rec;
              EXIT WHEN c_rcv_ser_csr%NOTFOUND;
            ELSE
	        -- ER 7307189 changes start
		IF ( res_count > 0 ) THEN
			FETCH   ser_csr_reserved_lpn INTO    l_serial_rec;
			EXIT WHEN ser_csr_reserved_lpn%NOTFOUND;
		ELSE
			FETCH   ser_csr	INTO    l_serial_rec;
			EXIT WHEN ser_csr%NOTFOUND;
		END IF;
		-- ER 7307189 changes end

            END IF;

            l_serial := l_serial_rec.serial_number;

            IF (l_debug = 1) THEN
              mydebug('complete_putaway: SN:' || l_serial);
            END IF;

            --Since we would not be exploding the content LPN in the inventory TM
            --we have to create the MSNT records from here for the TM to process
            --This is applicable for putaway of an entire INV/WIP LPN when
            --WMS and PO J are installed
            IF ( (p_entire_lpn = 'N') OR
                 (l_txn_action_id IN(27, 12)) OR
                 (p_entire_lpn = 'Y' AND l_lpn_context IN (1,2))
              ) THEN
              -- Capture serial info for WIP transactions
        /* nsinghi - GME-WMS Integration. Added additional check for l_process_flag.
        Update Serial attrs from wip_lpn_completions_serials table only for discrete orgs. */

              IF (l_transaction_source_type_id = 5 AND l_process_flag = 'N') THEN
                IF (l_debug = 1) THEN
                  mydebug('complete_putaway: Capture serial atts from wip tables');
                  mydebug('p_ref_id: ===========> ' || l_ref_id);
                  mydebug('p_temp_id: ==========> ' || p_temp_id);
                  mydebug('p_fm_serial_number: => ' || l_serial);
                  mydebug('p_to_serial_number: => ' || l_serial);
                  mydebug('p_serial_temp_id: ===> ' || l_ser_seq);
                  mydebug('p_serial_flag: ======> ' || 2);
                END IF;

                wms_wip_integration.capture_serial_atts(
                  p_ref_id               => l_ref_id
                , p_temp_id              => p_temp_id
                , p_last_update_date     => SYSDATE
                , p_last_updated_by      => p_user_id
                , p_creation_date        => SYSDATE
                , p_created_by           => p_user_id
                , p_fm_serial_number     => l_serial
                , p_to_serial_number     => l_serial
                , p_serial_temp_id       => l_ser_seq
                , p_serial_flag          => 2
                );
              ELSE
                l_result := TRUE;
                /*
                 * If INV and PO patch levels are J or higher, we will create
                 * create one MSNI record for each serial fetched above and
                 * link it to the MTLI record created above. No Temp records
                 */
                IF (l_lpn_context = 3) THEN
                  IF (l_debug = 1) THEN
                    mydebug('complete_putaway: Inserting MSNI - lot and serial item');
                  END IF;
                  --Call the helper routine to create the MSNI record
                  l_result := insert_msni_helper(
                        p_txn_if_id       =>  l_dup_ser_temp_id
                      , p_serial_number   =>  l_serial
                      , p_org_id          =>  p_org_id
                      , p_item_id         =>  p_item_id
                      , p_product_txn_id  =>  l_product_transaction_id
                      );

                  IF NOT l_result THEN
                    IF (l_debug = 1) THEN
                    mydebug('complete_putaway: Failure while Inserting MSNI records - lot and serial controlled item');
                    END IF;
                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;   --END IF check l_result

                  IF (l_debug = 1) THEN
                    mydebug('complete_putaway: Inserted MSNI for lot and serial item. intf_txn_id: '
                      || l_dup_ser_temp_id || ' , prod_txn_id: ' || l_product_transaction_id);
                  END IF;

                  --If the line is crossdocked, create MSNT also
                  IF (l_is_crossdocked) THEN
                    IF (l_debug = 1) THEN
                      mydebug('complete_putaway: Inserting MSNT for xdock - lot and serial item' || l_ser_seq);
                    END IF;
                    --Create one MSNT record for each serial number returned by
                    --the cursor
                    l_result := insert_msnt_rec(
                          p_transaction_temp_id =>  l_ser_seq
                        , p_serial_number       =>  l_serial
                        , p_serial_atts         =>  l_serial_rec
                        , p_user_id             =>  p_user_id);

                    IF NOT l_result THEN
                      IF (l_debug = 1) THEN
                        mydebug('complete_putaway: Failure while creating xdock MSNT - lot and serial');
                      END IF;
                      RAISE fnd_api.g_exc_unexpected_error;
                    END IF;   --END IF check l_result
                  END IF;  --END IF insert MSNT for xdock

		--LPN is not receiving LPN
                ELSE
                  IF (l_debug = 1) THEN
                    mydebug('complete_putaway: Inserting MSNT - lot and serial item' || l_ser_seq);
                  END IF;
                  --Create one MSNT record for each serial number returned by
                  --the cursor
                  l_result := insert_msnt_rec(
                        p_transaction_temp_id =>  l_ser_seq
                      , p_serial_number       =>  l_serial
                      , p_serial_atts         =>  l_serial_rec
                      , p_user_id             =>  p_user_id);

                  IF NOT l_result THEN
                    IF (l_debug = 1) THEN
                      mydebug('complete_putaway: Failure while MSNT');
                    END IF;
                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;   --END IF check l_result
                END IF;   --END IF (l_lpn_context = 3) THEN
              END IF;   --END IF check transaction_source_type = 5clear scr
            END IF;   --END IF p_entire_lpn = 'N'

            /*
             * Do not update MTL_SERIAL_NUMBERS from here if the LPN Resides in
             * Receiving and WMS and PO patch levels are J or higher
             * For other LPN contexts and if patch levels are lower than J,
             * continue with the updates
             */
            IF (l_lpn_context = 3) THEN
              IF l_debug = 1 THEN
                mydebug('complete_putaway: The LPN resides in Receiving. No updates to MSN from here.');
              END IF;
            --INV/WIP LPN
            ELSE
              IF l_debug = 1 THEN
                mydebug('complete_putaway: INV/WIP LPN. Update MSN.');
              END IF;

              -- Update MSN's group_mark_id
              UPDATE mtl_serial_numbers
              SET group_mark_id = p_temp_id
              WHERE  serial_number = l_serial
              AND    inventory_item_id = p_item_id
              AND    lot_number = p_lot;

              -- Bug 2458540
              -- Update the Serial Status to 4 before calling Receiving Transaction
              -- Processor for RMA serial At SALES ORDER ISSUE STANDARD RECEIPT CASE
              IF (l_serial_code = 6 AND l_ref = 'ORDER_LINE_ID') THEN
                UPDATE mtl_serial_numbers
                SET current_status = 4
                  , previous_status = current_status
                WHERE  serial_number = l_serial
                AND    inventory_item_id = p_item_id
                AND    lot_number = p_lot;
              END IF;
            END IF;   --END IF (l_lpn_context = 3) T
          END LOOP;   --END IF loop through serials in lot

          IF ser_csr%ISOPEN THEN
            CLOSE ser_csr;
          END IF;

	 -- ER 7307189 changes start
	 IF ser_csr_reserved_lpn%ISOPEN THEN
		CLOSE ser_csr_reserved_lpn;
	 END IF;
	 -- ER 7307189 changes end

          IF c_rcv_ser_csr%ISOPEN THEN
            CLOSE c_rcv_ser_csr;
          END IF;
        END IF;   -- End Serial Loop
      -- Bug 2458540
      -- ELSIF l_serial_code>1 AND l_serial_code<>6 THEN
      --not lot controlled
      --4049874 : removed the l_wms_po_j_or_higher check
      ELSIF((l_serial_code > 1 AND l_serial_code <> 6)
            OR ( l_serial_code = 6 AND l_ref = 'ORDER_LINE_ID')
            OR ( l_serial_code = 6 AND  l_ref = 'SHIPMENT_LINE_ID'
                 AND l_is_msni_req > 0
              )
           ) THEN
        IF (l_debug = 1) THEN
          mydebug('complete_putaway: serial item only');
        END IF;

	-- ER 7307189 changes start

	SELECT  COUNT(msn.group_mark_id)
        INTO    res_count
        FROM    mtl_serial_numbers msn ,
                mtl_reservations mr
        WHERE   mr.lpn_id        =msn.lpn_id
              AND msn.group_mark_id=mr.reservation_id
              AND msn.lpn_id       = p_lpn_id;

        mydebug(' complete_putaway : res_count value ' || res_count);

       -- ER 7307189 changes end


        /* FP-J Lot/Serial Support Enhancement
         * If the MOL LPN context is "RESIDES IN RECEIVING" and INV and PO Patch
         * levels are J or higher, then open the cursor c_rcv_ser_csr that
         * fetches the serial by matches the serials in rcv_serials_supply for
         * the parent transaction
         * If either of these is not true, then open the original cursor
         */
        IF (l_lpn_context = 3) THEN
          OPEN c_rcv_ser_csr;
        ELSE

	  -- ER 7307189 changes start
          IF ( res_count > 0 ) THEN
                  OPEN ser_csr_reserved_lpn;
          ELSE
                  OPEN ser_csr;
          END IF;
	  -- ER 7307189 changes end

        END IF;

        LOOP
          IF (l_lpn_context = 3) THEN
            FETCH c_rcv_ser_csr INTO l_serial_rec;
            EXIT WHEN c_rcv_ser_csr%NOTFOUND;
          ELSE
	    -- ER 7307189 changes start
            IF ( res_count > 0 ) THEN
                    FETCH   ser_csr_reserved_lpn  INTO    l_serial_rec;
                    EXIT WHEN ser_csr_reserved_lpn%NOTFOUND;
            ELSE
                    FETCH   ser_csr INTO    l_serial_rec;
                    EXIT WHEN ser_csr%NOTFOUND;
            END IF;
	    -- ER 7307189 changes end
          END IF;

          l_serial := l_serial_rec.serial_number;

          /*IF p_entire_lpn = 'N'
             OR l_txn_action_id IN(27, 12) THEN*/

          --Since we would not be exploding the content LPN in the inventory TM
          --we have to create the MSNT records from here for the TM to process
          --This is applicable for putaway of an entire INV/WIP LPN when
          --WMS and PO J are installed
          IF ( (p_entire_lpn = 'N') OR
                 (l_txn_action_id IN(27, 12)) OR
                 (p_entire_lpn = 'Y' AND l_lpn_context IN (1,2))
              ) THEN
            -- Capture serial info for WIP transactions
            IF l_transaction_source_type_id = 5 THEN
              IF (l_debug = 1) THEN
                mydebug('complete_putaway: Capture serial atts from wip tables');
                mydebug('p_ref_id: ===========> ' || l_ref_id);
                mydebug('p_temp_id: ==========> ' || p_temp_id);
                mydebug('p_fm_serial_number: => ' || l_serial);
                mydebug('p_to_serial_number: => ' || l_serial);
                mydebug('p_serial_temp_id: ===> ' || p_temp_id);
                mydebug('p_serial_flag: ======> ' || 3);
              END IF;

              wms_wip_integration.capture_serial_atts(
                p_ref_id               => l_ref_id
              , p_temp_id              => p_temp_id
              , p_last_update_date     => SYSDATE
              , p_last_updated_by      => p_user_id
              , p_creation_date        => SYSDATE
              , p_created_by           => p_user_id
              , p_fm_serial_number     => l_serial
              , p_to_serial_number     => l_serial
              , p_serial_temp_id       => p_temp_id
              , p_serial_flag          => 3
              );
            ELSE
              l_result := TRUE;

              /* FP-J Lot/Serial Support Enhancement
               * If the LPN Resides in Receiving and WMS and PO patch levels
               * are J or higher, we can create one MSNI record for each serial
               * fetched from the cursor. No MSNT records needed here
               */
              IF (l_lpn_context = 3) THEN
                IF (l_debug = 1) THEN
                  mydebug('complete_putaway: Inserting MSNI - serial controlled only' || p_temp_id);
                END IF;

                IF l_product_transaction_id IS NULL THEN
                  SELECT  rcv_transactions_interface_s.NEXTVAL
                  INTO    l_product_transaction_id
                  FROM    sys.dual;
                END IF;

                --Call the helper routine to create the MSNI record
                l_result := insert_msni_helper(
                      p_txn_if_id       =>  l_dup_temp_id
                    , p_serial_number   =>  l_serial
                    , p_org_id          =>  p_org_id
                    , p_item_id         =>  p_item_id
                    , p_product_txn_id  =>  l_product_transaction_id);

                IF NOT l_result THEN
                  IF (l_debug = 1) THEN
                  mydebug('complete_putaway: Failure while Inserting MSNI records - serial controlled item');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;   --END IF check l_result
		IF (l_debug = 1) THEN
		   mydebug('complete_putaway: Inserting MSNT for xdock - serial item' || l_ser_seq);
		END IF;

		--If the line croosdocked, create one MSNT record for each serial number returned by the cursor
                IF (l_is_crossdocked) THEN
		  l_result := insert_msnt_rec(
  		      p_transaction_temp_id =>  p_temp_id
	            , p_serial_number       =>  l_serial
	            , p_serial_atts         =>  l_serial_rec
	           , p_user_id              =>  p_user_id);

	  	  IF NOT l_result THEN
		    IF (l_debug = 1) THEN
		       mydebug('complete_putaway: Failure while MSNT');
		    END IF;
		    RAISE fnd_api.g_exc_unexpected_error;
		  END IF;   --END IF check l_result
                END IF;  --END IF create MSNT for xdock

	       --INV/WIP LPN
	       ELSE
                IF (l_debug = 1) THEN
                   mydebug('complete_putaway: Inserting MSNT - serial controlled only' || p_temp_id);
                   mydebug('complete_putaway p_temp_id:'|| p_temp_id);
                   mydebug('complete_putaway l_serial:'|| l_serial);
                END IF;

                 /* Bug 5213359-Added the following check */

                SELECT count(transaction_temp_id)
                INTO l_exist_msnt
                FROM mtl_serial_numbers_temp
                WHERE transaction_temp_id = p_temp_id
                AND fm_serial_number = l_serial ;

                mydebug('complete_putaway In patchset J, checking for msnt l_exist_msnt:'|| l_exist_msnt);

                IF l_exist_msnt = 0 THEN
                 --Create one MSNT record for each serial number returned by the cursor
                   l_result := insert_msnt_rec(
                         p_transaction_temp_id =>  p_temp_id
                       , p_serial_number       =>  l_serial
                       , p_serial_atts         =>  l_serial_rec
                       , p_user_id             =>  p_user_id);
                END IF;

                /* End of fix for Bug 5213359*/

                IF NOT l_result THEN
                  IF (l_debug = 1) THEN
                    mydebug('complete_putaway: Failure while Inserting MSNT - serial controlled only');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;   --END IF check l_result
              END IF;   --END IF (l_lpn_context = 3) THEN
            END IF;   --END IF l_transaction_source_type_id = 5
          END IF;   --END IF p_entire_lpn = 'N'

          /*
           * Do not update MTL_SERIAL_NUMBERS from here if the LPN Resides in
           * Receiving and WMS and PO patch levels are J or higher
           * For other LPN contexts and if patch levels are lower than J,
           * continue with the updates
           */
          IF (l_lpn_context = 3) THEN
            IF l_debug =1 THEN
              mydebug('complete_putaway: LPN Resides in Receiving. No updates to MSN from here.');
            END IF;
          --WMS or PO are lower than J - have to update MSN
         ELSE
           IF l_debug =1 THEN
             mydebug('complete_putaway: INV/WIP LPN. ');
           END IF;

           -- Update MSN's group_mark_id
            UPDATE mtl_serial_numbers
            SET group_mark_id = p_temp_id
            WHERE  serial_number = l_serial
            AND    inventory_item_id = p_item_id;

            -- Bug 2458540
            -- Update the Serial Status to 4 before calling Receiving Transaction
            -- Processor for RMA serial At SALES ORDER ISSUE STANDARD RECEIPT CASE
            IF (l_serial_code = 6 AND l_ref = 'ORDER_LINE_ID') THEN
              UPDATE mtl_serial_numbers
              SET current_status = 4
                , previous_status = current_status
              WHERE  serial_number = l_serial
              AND    inventory_item_id = p_item_id;
            END IF;
          END IF;   --END IF (l_lpn_context = 3)
        END LOOP;

        IF ser_csr%ISOPEN THEN
          CLOSE ser_csr;
        END IF;
         -- ER 7307189 changes start
	 IF ser_csr_reserved_lpn%ISOPEN THEN
		CLOSE ser_csr_reserved_lpn;
	 END IF;
	 -- ER 7307189 changes end
        IF c_rcv_ser_csr%ISOPEN THEN
          CLOSE c_rcv_ser_csr;
        END IF;
      END IF; -- End Lot Loop
    --If there is a quantity discrepancy
    ELSIF (p_disc = 'Y') THEN
      /*
       * If the MOL LPN context is "RESIDES IN RECEIVING" and INV and PO Patch
       * levels are J or higher then MSNI records would have been created before
       * calling complete_putaway, one per serial number.
       * Over here we need to match the serials confirmed in the UI against the
       * serials in RCV_SERIALS_SUPPLY for the parent transaction
       * Get the parent transaction from the current MOL and check for serials
       * that exist in MSNI but not in RCV_SERIALS_SUPPLY. If at least one such
       * serial is found, then error out the transaction since match failed
       */
      IF (l_lpn_context = 3) THEN

        --In case of quantity discrepancy, the MTLI/MSNI record would be created
        --in the UI itself and we get the product_transaction_id from there
        --So, we just need to assign this value to the local variable and subsequently
        --pass it the transfer/deliver API for lot/serial splits
        l_product_transaction_id := p_product_transaction_id;
        --4049874
        IF ((l_serial_code > 1  AND l_serial_code <> 6) OR
            (l_serial_code = 6  AND (l_ref = 'ORDER_LINE_ID' OR l_ref = 'SHIPMENT_LINE_ID'))) THEN

          --If the line is crossdocked then insert the MSNT records for the serials
          --that were confirmed in the UI (using product_transaction_id)
          IF (l_is_crossdocked) THEN
	    IF (l_lot_code > 1) THEN
	       SELECT serial_transaction_temp_id
		 INTO   l_msnt_temp_id
		 FROM   mtl_transaction_lots_interface
		 WHERE  lot_number = p_lot
		 AND    product_transaction_id = l_product_transaction_id;
	     ELSE
	       l_msnt_temp_id := p_temp_id;
            END IF;

            IF (l_debug = 1) THEN
              mydebug('complete_putaway: Case when p_disc = Y. l_msnt_temp_id:'||l_msnt_temp_id);
            END IF;

	    OPEN c_msni_ser_csr(l_product_transaction_id);
  	    LOOP
	     FETCH c_msni_ser_csr INTO l_serial_rec;
	     EXIT WHEN c_msni_ser_csr%NOTFOUND;
	     l_fm_serial := l_serial_rec.serial_number;
	     l_to_serial := l_serial_rec.to_serial_number;
	     l_result := insert_msnt_rec(
		 p_transaction_temp_id =>  l_msnt_temp_id
               , p_serial_number       =>  l_fm_serial
               , p_serial_atts         =>  l_serial_rec
               , p_user_id             =>  p_user_id
               , p_to_serial_number    =>  l_to_serial);
	     IF NOT l_result THEN
	       IF (l_debug = 1) THEN
		   mydebug('complete_putaway: Failure while Inserting MSNT - qty disc');
		END IF;
		IF c_msni_ser_csr%ISOPEN THEN
		  CLOSE c_msni_ser_csr;
		END IF;
		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;   --END IF check l_result
	  END LOOP;
	  IF c_msni_ser_csr%ISOPEN THEN
	     CLOSE c_msni_ser_csr;
	  END IF;
         END IF;   --END IF line is crossdocked
        END IF;   --Item is serial controlled
      ELSE
        --If the LPN is an INV/ WIP LPN and there is a quantity discrepancy,
        --for an item that is lot controlled and not serial controlled, then
        --update the MTLT record with the user confirmed quantity
        --This update statement should be executed if
        --  a) WMS and PO Patchset levels are less than J (for LPN contexts)
        --  b) If the LPN is an INV/WIP LPN (if patchset levels are > j)
        IF ((l_lot_code > 1) AND
            (l_serial_code = 1 OR (l_serial_code = 6 AND l_ref <> 'ORDER_LINE_ID'))) THEN
          -- Calculate Primary Quantity
          l_pr_qty := wms_task_dispatch_gen.get_primary_quantity(
                  p_item_id         => p_item_id
                , p_organization_id => p_org_id
                , p_from_quantity   => l_qty
                , p_from_unit       => p_uom);

          IF (l_debug = 1) THEN
            mydebug('complete_putaway: primary qty: ' || l_pr_qty);
          END IF;
          UPDATE mtl_transaction_lots_temp
          SET transaction_quantity = l_qty
            , primary_quantity = l_pr_qty
            , last_update_date = SYSDATE
            , last_updated_by = p_user_id
          WHERE  transaction_temp_id = p_temp_id
          AND    lot_number = p_lot;
        END IF;
      END IF;   --END IF check patch levels and LPN context
    END IF; -- End disc if

    IF (l_debug = 1) THEN
      mydebug(
           'complete_putaway: :'
        || p_org_id
        || ':'
        || l_ref_id
        || ':'
        || l_ref
        || ':'
        || l_ref_type
        || ':'
        || p_item_id
        || ':'
        || p_rev
        || ':'
        || p_sub
        || ':'
        || p_loc
        || ':'
        || l_qty
        || ':'
        || p_uom
        || ':'
        || p_temp_id
        || ':'
        || l_lot_code
        || ':'
        || l_serial_code
      );
    END IF;

     --Bug 3989684 Start
           UPDATE mtl_material_transactions_temp
           SET  transaction_header_id = l_txn_header_id
           WHERE  transaction_temp_id = p_temp_id;
       --Bug 3989684 End

    -- Call Amins Log exceptions
    IF (p_qty_reason_id > 0) THEN
      --Log exception
      IF (l_debug = 1) THEN
        mydebug('Logging exception for qty discrepancy');
        mydebug('txn_header_id: ' || l_txn_header_id);
      END IF;


      l_mmtt_id := p_temp_id;

      wms_txnrsn_actions_pub.log_exception(
        p_api_version_number     => 1.0
      , p_init_msg_lst           => fnd_api.g_false
      , p_commit                 => fnd_api.g_false
      , x_return_status          => x_return_status
      , x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      , p_organization_id        => p_org_id
      , p_mmtt_id                => l_mmtt_id
      , p_task_id                => l_txn_header_id
      , p_reason_id              => p_qty_reason_id
      , p_subinventory_code      => p_sub
      , p_locator_id             => p_loc
      , p_discrepancy_type       => 2
      , p_user_id                => l_emp_id --p_user_id Bug 2672785
      , p_item_id                => p_item_id
      , p_revision               => p_rev
      , p_lot_number             => p_lot
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF (p_loc_reason_id > 0) THEN
      --Log exception
      IF (l_debug = 1) THEN
        mydebug('Logging exception for loc discrepancy');
        mydebug('txn_header_id: ' || l_txn_header_id);
      END IF;

      l_mmtt_id := p_temp_id;

      wms_txnrsn_actions_pub.log_exception(
        p_api_version_number     => 1.0
      , p_init_msg_lst           => fnd_api.g_false
      , p_commit                 => fnd_api.g_false
      , x_return_status          => x_return_status
      , x_msg_count              => x_msg_count
      , x_msg_data               => x_msg_data
      , p_organization_id        => p_org_id
      , p_mmtt_id                => l_mmtt_id
      , p_task_id                => l_txn_header_id
      , p_reason_id              => p_loc_reason_id
      , p_subinventory_code      => p_sub
      , p_locator_id             => p_loc
      , p_discrepancy_type       => 2
      , p_user_id                => l_emp_id --p_user_id Bug 2672785
      , p_item_id                => p_item_id
      , p_revision               => p_rev
      , p_lot_number             => p_lot
      , p_is_loc_desc            => TRUE  --Changes for Bug 3989684
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_LOG_EXCEPTION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    --If the LPN context is Resides in Receiving
    IF (l_lpn_context = 3) THEN
      IF (l_debug = 1) THEN
        mydebug('complete_putaway: Rcving LPN..');
        mydebug('complete_putaway: Updating mmtt info...');
        mydebug('complete_putaway: To LPN' || l_to_lpn_id);
        mydebug('complete_putaway: Entire LPN' || p_entire_lpn);
      END IF;

      IF (p_entire_lpn = 'N') THEN
        --Bug 2074100 Fix
        IF (l_debug = 1) THEN
          mydebug('complete_putaway: not ent lpn');
        END IF;

        IF ((l_del_detail_id IS NOT NULL)
            AND(l_crossdock_type = 2)
            AND(l_wip_supply_type = 1)) THEN
          IF (l_debug = 1) THEN
            mydebug(' This is a crossdocked line for wip issue ');
            mydebug(' setting transfer_lpn to null ');
	  END IF;
	  --This is Receiving LPN, we have to update header_id as we need
	  -- one for each txn
	  --We always will generate new txn header id for a receiving lpn due to the
	  --problem in join between WDTH and MMT for the deliver transaction
	  UPDATE mtl_material_transactions_temp
            SET  transaction_header_id = l_txn_header_id
            WHERE  transaction_temp_id = p_temp_id;
        ELSE
          IF (l_debug = 1) THEN
            mydebug(' In else for checking wip issue ');
          END IF;

	  IF (l_debug =1 ) THEN
	     mydebug('Update only transfer LPN ID to NULL');
	  END IF;

	  UPDATE mtl_material_transactions_temp
            SET  transaction_header_id = l_txn_header_id
            WHERE  transaction_temp_id = p_temp_id;
        END IF; --IF ((l_del_detail_id IS NOT NULL) AND(l_crossdock_type = 2) AND(l_wip_supply_type = 1))
      ELSE
        IF (l_debug = 1) THEN
          mydebug('complete_putaway: updating mmtt with content lpn');
        END IF;

        -- COMMIT;
	IF l_debug = 1 THEN
	   mydebug('Updating content LPN ID for inventory/WIP LPNs ');
	END IF;

	UPDATE mtl_material_transactions_temp
          SET  transaction_header_id = l_txn_header_id
          WHERE  transaction_temp_id = p_temp_id;

	IF (l_debug = 1) THEN
	   mydebug('complete_putaway: after updating mmtt with content lpn');
        END IF;
      END IF;--END IF (p_entire_lpn = 'N') THEN

      -- Have to update WMS_Exceptions so that any exceptions already
      -- recorded for this MMTT line will now be updated with the new txn
      -- header_id
      -- Bug# 3434940 - Performance Fixes
      -- Go against the org and item which are input params for
      -- complete_putaway since this will make use of the index in
      -- WMS_EXCEPTIONS
      UPDATE wms_exceptions
	SET transaction_header_id = l_txn_header_id
	WHERE  transaction_header_id = l_orig_txn_header_id
	AND organization_id = p_org_id
	AND inventory_item_id = p_item_id;

      IF (l_debug = 1) THEN
        mydebug('complete_putaway : Calling Workflow from complete_putaway');
      END IF;

      -- Call the workflows

      l_wf := 0;

      IF (p_qty_reason_id > 0) THEN
        BEGIN
          SELECT 1
          INTO   l_wf
          FROM   mtl_transaction_reasons
          WHERE  reason_id = p_qty_reason_id
          AND    workflow_name IS NOT NULL
          AND    workflow_name <> ' '
          AND    workflow_process IS NOT NULL
          AND    workflow_process <> ' ';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_wf := 0;
        END;

        IF l_wf > 0 THEN
          IF (l_debug = 1) THEN
            mydebug(' complete_putaway : WF exists for this reason code: ' || p_qty_reason_id);
            mydebug('complete_putaway : Calling workflow wrapper FOR qty');
          END IF;

          -- Calling Workflow
          wms_workflow_wrappers.wf_wrapper(
            p_api_version         => 1.0
          , p_init_msg_list       => fnd_api.g_false
          , p_commit              => fnd_api.g_false
          , x_return_status       => x_return_status
          , x_msg_count           => x_msg_count
          , x_msg_data            => x_msg_data
          , p_org_id              => p_org_id
          , p_rsn_id              => p_qty_reason_id
          , p_calling_program     => 'complete_putaway - for qty discrepancy - loose'
          , p_tmp_id              => p_temp_id
          , p_quantity_picked     => l_qty
          , p_dest_sub            => l_org_sub
          , p_dest_loc            => l_org_loc
          );

          IF (l_debug = 1) THEN
            mydebug('complete_putaway : After Calling WF Wrapper');
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              mydebug('complete_putaway : Error callinf WF wrapper');
            END IF;

            fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              mydebug('complete_putaway : Error calling WF wrapper');
            END IF;

            fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      -- call workflow for location discrepancy
      l_wf := 0;

      IF (p_loc_reason_id > 0) THEN
        -- update MMTT with reason id = p_loc_reason_id. (bugfix 4294713)
	update mtl_material_transactions_temp
	set reason_id = p_loc_reason_id
	where transaction_temp_id = p_temp_id;

        BEGIN
	   SELECT 1,
	     workflow_process
	     INTO   l_wf,
	     l_wf_process
	     FROM   mtl_transaction_reasons
	     WHERE  reason_id = p_loc_reason_id
	     AND    workflow_name IS NOT NULL
	     AND    workflow_name <> ' '
	     AND    workflow_process IS NOT NULL
	     AND    workflow_process <> ' ';
        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
            l_wf := 0;
            l_wf_process := null; --Bugfix 4294713
        END;

	IF (  ( l_wf_process IS NOT NULL               --Bugfix 4294713
                AND
                l_wf_process <> 'WMS_N_STEP_PUTAWAY'
               )
               OR
	       l_operation_plan_id IS NULL
           ) THEN
	   IF l_wf > 0 THEN
	      IF (l_debug = 1) THEN
		 mydebug(' complete_putaway : WF exists for this reason code: ' || p_loc_reason_id);
		 mydebug('complete_putaway : Calling workflow wrapper FOR location');
		 mydebug('dest sub: ' || p_sub);
		 mydebug('dest loc: ' || p_loc);
	      END IF;

	      -- Calling Workflow
	      wms_workflow_wrappers.wf_wrapper(
					       p_api_version         => 1.0
					       , p_init_msg_list       => fnd_api.g_false
					       , p_commit              => fnd_api.g_false
					       , x_return_status       => x_return_status
					       , x_msg_count           => x_msg_count
					       , x_msg_data            => x_msg_data
					       , p_org_id              => p_org_id
					       , p_rsn_id              => p_loc_reason_id
					       , p_calling_program     => 'complete_putaway - for loc discrepancy - loose'
					       , p_tmp_id              => p_temp_id
					       , p_quantity_picked     => NULL
					       , p_dest_sub            => l_org_sub
					       , p_dest_loc            => l_org_loc
					       );

	      IF (l_debug = 1) THEN
		 mydebug('complete_putaway : After Calling WF Wrapper');
	      END IF;

	      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 IF (l_debug = 1) THEN
		    mydebug('complete_putaway : Error callinf WF wrapper');
		 END IF;

		 fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_unexpected_error;
	       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
		 IF (l_debug = 1) THEN
		    mydebug('complete_putaway : Error calling WF wrapper');
		 END IF;

		 fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;
	   END IF;--END IF l_wf > 0 THEN
	END IF; -- END IF IF (( l_wf_process IS NOT NULL AND l_wf_process <> 'WMS_N_STEP_PUTAWAY') OR l_operation_plan_id IS NULL)
      END IF;--IF (p_loc_reason_id > 0) THEN

      -- bug 2271470
      -- This MMTT record has been putaway by the user,
      -- therefore we don't want this record being seen
      -- again if user scans the same LPN.
      -- Therefore we update wms_task_type column to -1 as a flag
      -- signifying this MMTT record should not be
      -- shown in the putaway drop page again.
      -- In putaway drop page, we make sure those MMTT
      -- with wms_task_type of -1 not selected.

      UPDATE mtl_material_transactions_temp
      SET wms_task_type = -1
      WHERE  transaction_temp_id = p_temp_id;

      IF (l_debug = 1) THEN
        mydebug('complete_putaway: Calling Karuns API');
      END IF;

      /* FP-J Lot/Serial Support Enhancement
       * If the LPN Context is Resides in Receiving, then do the following:
       *  IF INV J and PO J are installed Then
       *    Check subinventory type of the drop subinventory
       *    If destination sub is receiving subinventory Then
       *      Call the Transfer API
       *    Else
       *      Set the variable p_transaction_temp_id to product_transaction_id
       *      Call the Deliver API
       *    End If
       *  Else
       *    Set the value of p_transaction_temp_id to l_dup_temp_id
       *    Retain the old code to call deliver API by passing NULL values for
       *    the new parameters
       *  End If;
       */

      l_drop_sub_type := wms_putaway_utils.get_subinventory_type(p_organization_id   =>  p_org_id
								 , p_subinventory_code =>  p_sub);

      IF (l_drop_sub_type < 0) THEN
	 fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
	 fnd_msg_pub.add;
	 IF (l_debug = 1) THEN
            mydebug('complete_putaway: Error fetching drop subinventory type');
	 END IF;
	 RAISE fnd_api.g_exc_error;
      END IF;

      --Update the wms_process_flag to 2 so that one can work with
      --with this move order line from elsewhere
      UPDATE mtl_txn_request_lines
	SET wms_process_flag = 2
	WHERE line_id = l_mo_line_id;

      --Storage subinventory - Call Deliver API
      IF l_drop_sub_type = 1 THEN
	 IF (l_debug = 1) THEN
            mydebug('complete_putaway: Calling the deliver API with product_transaction_id: ' || l_product_transaction_id ||
		    ', from lpn, ' || l_mo_lpn_id || ', xfer_lpn_id: ' ||  l_to_lpn_id || ' lot_num: ' || l_mol_lot_number);
	 END IF;

	 --R12
	 inv_rcv_std_deliver_apis.Match_putaway_rcvtxn_intf_rec
	   (p_organization_id            => p_org_id
	    , p_reference_id               => l_ref_id
	    , p_reference                  => l_ref
	    , p_reference_type_code        => l_ref_type
	    , p_item_id                    => p_item_id
	    , p_revision                   => p_rev
	    , p_subinventory_code          => p_sub
	    , p_locator_id                 => p_loc
	    , p_rcvtxn_qty                 => l_qty
	    , p_rcvtxn_uom_code            => p_uom
	    , p_transaction_temp_id        => l_product_transaction_id
	    , p_lot_control_code           => l_lot_code
	    , p_serial_control_code        => l_serial_code
	    , p_original_txn_temp_id       => p_temp_id
	    , x_return_status              => x_return_status
	    , x_msg_count                  => x_msg_count
	    , x_msg_data                   => x_msg_data
	    , p_inspection_status_code     => l_inspection_status
	    , p_lpn_id                     => l_mo_lpn_id
	    , p_transfer_lpn_id            => l_to_lpn_id
	    , p_lot_number                 => l_mol_lot_number
	   , p_parent_txn_id              => l_parent_txn_id
	   , p_secondary_quantity         => p_secondary_quantity --OPM Integration
	   , p_secondary_uom              => p_secondary_uom --OPM Integration
	   , p_inspection_status     => l_inspection_status
	   , p_primary_uom_code      => p_primary_uom
	   );
	 IF (l_debug = 1) THEN
            mydebug('complete_putaway: After  Karuns Delivery API');
	 END IF;

	 IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            fnd_message.set_name('WMS', 'WMS_TD_DEL_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            fnd_message.set_name('WMS', 'WMS_TD_DEL_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
	 END IF;
	 --Receiving subinventory - Call Transfer API
       ELSE
	 IF (l_debug = 1) THEN
            mydebug('complete_putaway: Calling the Transfer API');
	 END IF;

	 --R12
	 inv_rcv_std_transfer_apis.Match_transfer_rcvtxn_rec
	   (x_return_status       =>  x_return_status
            , x_msg_count           =>  x_msg_count
            , x_msg_data            =>  x_msg_data
            , p_organization_id     =>  p_org_id
            , p_parent_txn_id       =>  l_parent_txn_id
            , p_reference_id        =>  l_ref_id
            , p_reference           =>  l_ref
            , p_reference_type_code =>  l_ref_type
            , p_item_id             =>  p_item_id
            , p_revision            =>  p_rev
            , p_subinventory_code   =>  p_sub
            , p_locator_id          =>  p_loc
            , p_transfer_quantity   =>  l_qty
            , p_transfer_uom_code   =>  p_uom
            , p_lot_control_code    =>  l_lot_code
            , p_serial_control_code =>  l_serial_code
            , p_original_rti_id     =>  l_product_transaction_id
            , p_original_temp_id    =>  p_temp_id
            , p_lot_number          =>  l_mol_lot_number
            , p_lpn_id              =>  l_mo_lpn_id
	   , p_transfer_lpn_id     =>  l_to_lpn_id
	   , p_sec_transfer_quantity   =>  p_secondary_quantity--OPM Integration
	   , p_sec_transfer_uom_code   =>  p_secondary_uom --OPM Integration
	   , p_inspection_status     => l_inspection_status
	   , p_primary_uom_code      => p_primary_uom
	   );
	 IF (l_debug = 1) THEN
            mydebug('complete_putaway: After Transfer API');
	 END IF;

	 IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            fnd_message.set_name('WMS', 'WMS_TASK_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
	 END IF;
      END IF;   --END IF check sub type to call the corresponding API

      IF (l_debug = 1) THEN
        mydebug(' updating WDT with the group id');
      END IF;

      UPDATE wms_dispatched_tasks
      SET task_group_id = inv_rcv_common_apis.g_rcv_global_var.interface_group_id
      WHERE  transaction_temp_id = p_temp_id;

      l_txn_mode := 2;

      -- Bug 2074100 Fix

      IF ((l_del_detail_id IS NOT NULL)
          AND(l_crossdock_type = 2)
          AND(l_wip_supply_type = 1)) THEN
        IF (l_debug = 1) THEN
          mydebug(' This is a crossdocked line for wip issue ');
          mydebug(' need to update the context of the from lpn   ');
        END IF;

	-- Bug# 3281512 - Performance Fixes
	-- Match against the org too otherwise we will do a full table
	-- scan on MMTT which is really bad.  Org is an indexed column.
	-- Bug# 3434940 - Performance fixes
	-- Use an EXISTS instead since we are just checking for existence
	-- of any MMTT records for the given LPN.  Also use the item
	-- passed as an input parameter into complete_putaway too so we
	-- can make use of the item/org index or the index on lpn_id.
	-- Note that content_lpn_id currently is not an indexed column.
        BEGIN
	   SELECT   1
	     INTO   cnt
	     FROM   DUAL
	     WHERE  EXISTS (SELECT 1
			    FROM   mtl_material_transactions_temp
			    WHERE  lpn_id = p_lpn_id
			    AND    organization_id = p_org_id
			    AND    inventory_item_id = p_item_id)
	     OR     EXISTS (SELECT 1
			    FROM   mtl_material_transactions_temp
			    WHERE  content_lpn_id = p_lpn_id
			    AND    organization_id = p_org_id
			    AND    inventory_item_id = p_item_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            cnt := 0;
        END;

        IF (l_debug = 1) THEN
          mydebug('cnt is ' || cnt);
        END IF;

       ELSE
        IF (l_debug = 1) THEN
          mydebug(' In else for checking for wip issue after tm');
          mydebug(' to upd the lpn context ');
        END IF;
      END IF;
    --For other LPN contexts (Resides in Inventory, Resides in WIP)
    ELSE
      -- Set mode to normal
      l_txn_mode := 1;

      IF (l_debug = 1) THEN
        mydebug('complete_putaway: INV or WIP LPN');
        mydebug('complete_putaway: Updating mmtt info...');
        mydebug('complete_putaway: To LPN :' || l_to_lpn_id);
        mydebug('complete_putaway: Entire LPN' || p_entire_lpn);
        mydebug('complete_putaway: lpn drop type ' || p_lpn_mode);
        mydebug('complete_putaway: from lpn ' || p_lpn_id );
      END IF;

	--Changes for bug 5403420
	 invttmtx.tdatechk(org_id           => p_org_id,
			   transaction_date => SYSDATE,
			   period_id        => l_acct_period_id,
			   open_past_period => l_open_past_period);

	 IF l_acct_period_id <= 0 THEN
	   fnd_message.set_name('INV', 'INV_NO_OPEN_PERIOD');
	   fnd_msg_pub.ADD;
	   RAISE fnd_api.g_exc_unexpected_error;
	 END IF;
	--End of changes for bug 5403420

      -- Nested LPN changes
      -- Update MMTT for drop entire LPN
      IF (l_debug = 1) THEN
	 mydebug('complete_putaway: Patchset J or above , Update MMTT');
	 -- ER 7307189 changes start
	 mydebug(' Update MMTT l_dest_loc_id with ' || l_dest_loc_id);
	 mydebug(' Update MMTT l_dest_sub with ' || l_dest_sub);
	 -- ER 7307189 changes end
      END IF;

      IF (p_lpn_id = l_to_lpn_id) THEN

	 IF (l_debug = 1) THEN
	    mydebug(' Update MMTT contet LPN_ID WITH ' || p_lpn_id);
	    mydebug(' Update MMTT cost_group_id with ' || l_cost_group_id);
	 END IF;

	 UPDATE mtl_material_transactions_temp
	   SET transaction_header_id = l_txn_header_id
	   , content_lpn_id = p_lpn_id
	   , lpn_id = NULL
	   , transaction_status = 3
	   , posting_flag = 'Y'
	   , cost_group_id = Decode(l_lpn_context,1,l_cost_group_id,cost_group_id)  --BUG 4134432,4475607
	   , transfer_cost_group_id = Decode(l_lpn_context,1,l_cost_group_id,transfer_cost_group_id)  --BUG 4134432, 4475607
           , transaction_date = sysdate --added per Karun and Saju's request 04/2006
           , acct_period_id = l_acct_period_id --Added for bug 5403420
	   WHERE  transaction_temp_id = p_temp_id;
       ELSE

	 IF (l_debug = 1) THEN
	    mydebug(' Update MMTT from lpn_id with ' || p_lpn_id);
	    mydebug(' Update MMTT to lpn_id with ' || l_to_lpn_id);
	    mydebug(' Update MMTT cost_group_id with ' || l_cost_group_id);
	 END IF;

	 UPDATE mtl_material_transactions_temp
	   SET transaction_header_id = l_txn_header_id
	   , lpn_id  = p_lpn_id
	   , content_lpn_id = NULL
	   , transfer_lpn_id = l_to_lpn_id
	   , transaction_status = 3
	   , posting_flag = 'Y'
	   , cost_group_id = Decode(l_lpn_context,1,l_cost_group_id,cost_group_id)  --BUG 4134432, 4475607
	   , transfer_cost_group_id = Decode(l_lpn_context,1,l_cost_group_id,transfer_cost_group_id)  --BUG 4134432,4475607
           , transaction_date = sysdate --added per Karun and Saju's request 04/2006
           , acct_period_id = l_acct_period_id --Added for bug 5403420
	   WHERE  transaction_temp_id = p_temp_id;

      END IF; --END IF (p_lpn_id = l_to_lpn_id) THEN


      -- Have to update WMS_Exceptions so that any excpetions already
      -- recorded for this MMTT line will now be updated with the new txn
      -- header_id
      -- Bug# 3434940 - Performance Fixes
      -- Go against the org and item which are input params for
      -- complete_putaway since this will make use of the index in
      -- WMS_EXCEPTIONS
      UPDATE wms_exceptions
	SET transaction_header_id = l_txn_header_id
	WHERE  transaction_header_id = l_orig_txn_header_id
	AND organization_id = p_org_id
	AND inventory_item_id = p_item_id;

      IF (l_debug = 1) THEN
        mydebug('Calling Workflow from complete_putaway');
      END IF;

      -- Call the workflows
      l_wf := 0;

      IF (p_qty_reason_id > 0) THEN
        BEGIN
          SELECT 1
          INTO   l_wf
          FROM   mtl_transaction_reasons
          WHERE  reason_id = p_qty_reason_id
          AND    workflow_name IS NOT NULL
          AND    workflow_name <> ' '
          AND    workflow_process IS NOT NULL
          AND    workflow_process <> ' ';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_wf := 0;
        END;

        IF l_wf > 0 THEN
          IF (l_debug = 1) THEN
            mydebug('complete_putaway : WF exists for this reason code: ' || p_qty_reason_id);
            mydebug('complete_putaway : Calling workflow wrapper FOR qty');
          END IF;

          -- Calling Workflow
          wms_workflow_wrappers.wf_wrapper(
            p_api_version         => 1.0
          , p_init_msg_list       => fnd_api.g_false
          , p_commit              => fnd_api.g_false
          , x_return_status       => x_return_status
          , x_msg_count           => x_msg_count
          , x_msg_data            => x_msg_data
          , p_org_id              => p_org_id
          , p_rsn_id              => p_qty_reason_id
          , p_calling_program     => 'complete_putaway - for qty discrepancy - loose'
          , p_tmp_id              => p_temp_id
          , p_quantity_picked     => l_qty
          , p_dest_sub            => l_org_sub
          , p_dest_loc            => l_org_loc
          );

          IF (l_debug = 1) THEN
            mydebug('complete_putaway : After Calling WF Wrapper');
          END IF;

          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            IF (l_debug = 1) THEN
              mydebug('complete_putaway : Error callinf WF wrapper');
            END IF;

            fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
            IF (l_debug = 1) THEN
              mydebug('complete_putaway : Error calling WF wrapper');
            END IF;

            fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF; --IF l_wf > 0 THEN
      END IF;--IF (p_qty_reason_id > 0) THEN

      -- call workflow for location discrepancy
      l_wf := 0;


      IF (p_loc_reason_id > 0) THEN
        -- update MMTT with reason id = p_loc_reason_id.(bugfix 4294713)
        update mtl_material_transactions_temp
        set reason_id = p_loc_reason_id
        where transaction_temp_id = p_temp_id;

        BEGIN
	   SELECT 1,
	     workflow_process
	     INTO   l_wf,
	     l_wf_process
	     FROM   mtl_transaction_reasons
	     WHERE  reason_id = p_loc_reason_id
	     AND    workflow_name IS NOT NULL
	     AND    workflow_name <> ' '
	     AND    workflow_process IS NOT NULL
	     AND    workflow_process <> ' ';
        EXCEPTION
	   WHEN NO_DATA_FOUND THEN
            l_wf := 0;
            l_wf_process := null; --Bugfix 4294713
        END;

	IF (  ( l_wf_process IS NOT NULL               --Bugfix 4294713
                AND
                l_wf_process <> 'WMS_N_STEP_PUTAWAY'
               )
               OR
	       l_operation_plan_id IS NULL
           ) THEN
	   -- Bug 3346762
	   IF (l_lpn_context=2) AND l_dest_sub IS NULL THEN
	      l_wf_temp_sub := l_org_sub;
	      l_wf_temp_loc := l_org_loc;
	    ELSE
	      l_wf_temp_sub := l_dest_sub;
	      l_wf_temp_loc := l_dest_loc_id;
	   END IF;

	   IF l_wf > 0 THEN
	      IF (l_debug = 1) THEN
		 mydebug(' complete_putaway : WF exists for this reason code: ' || p_loc_reason_id);
		 mydebug('complete_putaway : Calling workflow wrapper FOR location');
		 mydebug('dest sub: ' || p_sub);
		 mydebug('dest loc: ' || p_loc);
	      END IF;



	      -- Calling Workflow
	      wms_workflow_wrappers.wf_wrapper(
					       p_api_version         => 1.0
					       , p_init_msg_list       => fnd_api.g_false
					       , p_commit              => fnd_api.g_false
					       , x_return_status       => x_return_status
					       , x_msg_count           => x_msg_count
					       , x_msg_data            => x_msg_data
					       , p_org_id              => p_org_id
					       , p_rsn_id              => p_loc_reason_id
					       , p_calling_program     => 'complete_putaway - for loc discrepancy - loose'
					       , p_tmp_id              => p_temp_id
					       , p_quantity_picked     => NULL
					       , p_dest_sub            => l_wf_temp_sub
					       , p_dest_loc            => l_wf_temp_loc
					       );

	      IF (l_debug = 1) THEN
		 mydebug('complete_putaway : After Calling WF Wrapper');
	      END IF;

	      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
		 IF (l_debug = 1) THEN
		    mydebug('complete_putaway : Error callinf WF wrapper');
		 END IF;

		 fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_unexpected_error;
	       ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
		 IF (l_debug = 1) THEN
		    mydebug('complete_putaway : Error calling WF wrapper');
		 END IF;

		 fnd_message.set_name('WMS', 'WMS_WORK_FLOW_FAIL');
		 fnd_msg_pub.ADD;
		 RAISE fnd_api.g_exc_error;
	      END IF;
	   END IF;--END IF l_wf > 0 THEN
	END IF; --IF (( l_wf_process IS NOT NULL AND l_wf_process <> 'WMS_N_STEP_PUTAWAY') OR l_operation_plan_id IS NULL) THEN
      END IF;--END IF (p_loc_reason_id > 0) THEN

      IF l_transaction_source_type_id = 5 THEN
        IF (l_debug = 1) THEN
          mydebug('complete_putaway : calling wma_inv_wrappers.transferReservation');
          mydebug('l_ref_id: => ' || l_ref_id);
          mydebug('p_sub: ====> ' || p_sub);
          mydebug('p_loc: ====> ' || p_loc);
          mydebug('l_del_detail_id ====> ' || l_del_detail_id);
        END IF;

        --bug 2310251 for WIP Putaway, use the new business flow code
        l_business_flow_code := 35;

        IF (l_del_detail_id IS NULL  ) THEN

           /*9695544-We should not call wip api to xfer reservation in case of putaway of material from an LPN that has
                 xdock tasks as well. The reason is that the WIP reservation for xdock will be transferred by this call
                  while the actual xdock tasks are not yet dropped. This will create data inconsistency.
                On the other hand, we need to call this API is if it is a putaway of an  LPN because some one can create
                reservation for SO and supply as WIP and we need to transfer the reservation
            */

           BEGIN
              l_xdock_tasks_exists  := 'N';
              SELECT 'Y' INTO l_xdock_tasks_exists
              FROM MTL_TXN_REQUEST_LINES mtrl
              WHERE lpn_id= p_lpn_id
              AND line_id <> l_mo_line_id
              AND backorder_delivery_detail_id IS NOT NULL
              AND line_status <> 5
              AND ROWNUM<2; --we need to just check if one such row exists or not
           EXCEPTION
           WHEN OTHERS THEN
              IF (l_debug = 1) THEN
                   mydebug('complete_putaway :  query to fetch l_xdock_tasks_exists resulte din exception, but it is fine ');
              END IF;
              l_xdock_tasks_exists  := 'N';
           END ;

           IF (l_debug = 1) THEN
              mydebug('complete_putaway : l_xdock_tasks_exists: '||l_xdock_tasks_exists);
           END IF;

           IF ( l_xdock_tasks_exists = 'N' ) THEN
              wms_wip_integration.transfer_reservation(
                p_header_id             => l_ref_id
               , p_subinventory_code     => p_sub
               , p_locator_id            => p_loc
               , x_return_status         => x_return_status
               , x_msg_count             => x_msg_count
               , x_err_msg               => x_msg_data
              , p_temp_id               => p_temp_id
              );
          END IF;
      ELSE
          IF (l_debug = 1) THEN
            mydebug('complete_putaway :xdock flow . So call transfer_reservation is not needed');
          END IF;
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          IF (l_debug = 1) THEN
            mydebug('complete_putaway : wma_inv_wrappers.transferReservation - Unexpect error');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          IF (l_debug = 1) THEN
            mydebug('complete_putaway : wma_inv_wrappers.transferReservation - Expect error');
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      -- Added release level check for ATF_J3

      IF (l_debug = 1) THEN
	 mydebug('complete_putaway: Patchset J or higher. Call to Inventroy TM will be done in complete_putaway_wrapper ');
      END IF;

      -- 4515887 CHANGES START
      IF l_txn_action_id =31 AND l_txn_type_id= 44 THEN
	 IF (l_debug = 1) THEN
	    mydebug('complete_putaway: Calling create_snapshot');
	 END IF;
	 create_snapshot(p_temp_id,p_org_id);
      END IF;
      -- 4515887 CHANGES END

    END IF;

    -- Bug# 2795096
    -- Do a commit only if the input parameter is set to 'Y' = YES
    IF (p_commit = 'Y') THEN
      COMMIT;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('complete_putaway: done WITH API');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      -- Bug# 2744170
      -- Perform a rollback in the exception blocks
      ROLLBACK TO complete_putaway_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF ser_csr%ISOPEN THEN
        CLOSE ser_csr;
      END IF;
      -- ER 7307189 changes start
	 IF ser_csr_reserved_lpn%ISOPEN THEN
		CLOSE ser_csr_reserved_lpn;
	 END IF;
      -- ER 7307189 changes end
      IF c_rcv_ser_csr%ISOPEN THEN
        CLOSE c_rcv_ser_csr;
      END IF;
      IF (l_debug = 1) THEN
        mydebug('complete_putaway: Excection error - ' || SQLERRM);
      END IF;
    WHEN OTHERS THEN

      ROLLBACK TO complete_putaway_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF ser_csr%ISOPEN THEN
        CLOSE ser_csr;
      END IF;
      -- ER 7307189 changes start
	 IF ser_csr_reserved_lpn%ISOPEN THEN
		CLOSE ser_csr_reserved_lpn;
	 END IF;
      -- ER 7307189 changes end
      IF c_rcv_ser_csr%ISOPEN THEN
        CLOSE c_rcv_ser_csr;
      END IF;
      IF (l_debug = 1) THEN
        mydebug('complete_putaway: Others exception - ' || SQLERRM);
      END IF;
  END complete_putaway;

  /*changes for OPM are not needed in this procedure since this is not called post-patchset J */
  PROCEDURE discrepancy(
    p_lpn_id         IN             NUMBER
  , p_org_id         IN             NUMBER
  , p_temp_id        IN             NUMBER
  , p_qty            IN             NUMBER
  , p_uom            IN             VARCHAR2
  , p_user_id        IN             NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  ) IS
    l_orig_qty      NUMBER;
    l_orig_uom      VARCHAR2(3);
    l_mol_uom       VARCHAR2(3);
    l_line_id       NUMBER;
    l_item_id       NUMBER;
    l_temp_id       NUMBER;
    l_org_id        NUMBER;
    l_uom           VARCHAR2(3);
    l_qty           NUMBER;
    l_qty_diff      NUMBER;
    l_qty_diff_prim NUMBER;
    l_cnt1          NUMBER;
    l_debug         NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_temp_id := p_temp_id;
    l_org_id := p_org_id;
    l_uom := p_uom;
    l_qty := p_qty;

    SELECT transaction_quantity
         , transaction_uom
         , inventory_item_id
         , move_order_line_id
    INTO   l_orig_qty
         , l_orig_uom
         , l_item_id
         , l_line_id
    FROM   mtl_material_transactions_temp
    WHERE  transaction_temp_id = l_temp_id
    AND    organization_id = l_org_id;

    IF (l_uom <> l_orig_uom) THEN
      --mydebug('Converting uom');
      l_qty :=
        inv_convert.inv_um_convert(
          item_id           => l_item_id
        , PRECISION         => NULL
        , from_quantity     => l_qty
        , from_unit         => l_uom
        , to_unit           => l_orig_uom
        , from_name         => NULL
        , to_name           => NULL
        );
    END IF;

    -- Calculate the difference

    l_qty_diff := l_orig_qty - l_qty;
    -- Calculate the difference in terms of the primary uom

    l_qty_diff_prim :=
      wms_task_dispatch_gen.get_primary_quantity(
          p_item_id         => l_item_id
        , p_organization_id => l_org_id
        , p_from_quantity   => l_qty_diff
        , p_from_unit       => l_orig_uom);

    -- Update MMTT with new values for txn and primary qty

    UPDATE mtl_material_transactions_temp
    SET transaction_quantity = transaction_quantity - l_qty_diff
      , primary_quantity = primary_quantity - l_qty_diff_prim
    WHERE  transaction_temp_id = l_temp_id
    AND    organization_id = l_org_id;

    -- Update mtl_transaction_lots_temp, if necessary
    --calling this procedure
    /* Bug #2966531
     * Do not update MTLT again since they would already have been done before
     * coming here */
    /*
    BEGIN
     UPDATE mtl_transaction_lots_temp
     SET transaction_quantity = transaction_quantity-l_qty_diff,
         primary_quantity = primary_quantity-l_qty_diff_prim
     WHERE transaction_temp_id = l_temp_id;
    EXCEPTION
     WHEN OTHERS THEN
     NULL;
    END;*/

    --mydebug('After updating mmtt');
    -- Update MTL_TXN_REQUESTS_TABLE
    -- Since the uom code in mtl_txn_request_lines will always
    -- be the same as the transaction_uom in mmtt, no need to do the
    -- conversion again
    UPDATE mtl_txn_request_lines
    SET quantity_detailed = quantity_detailed - l_qty_diff
    WHERE  line_id = l_line_id
    AND    organization_id = l_org_id;
    --mydebug('After updating mol');

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END discrepancy;

  -- Important, please note that the input parameter, p_user_id
  -- does NOT refer to the fnd user id.  Instead it refers to the employee id.
  -- It is used against the wms_dispatched_tasks.person_id column which
  -- is populated with the employee id.
  PROCEDURE check_lpn_validity(
    p_org_id         IN             NUMBER
  , p_lpn_id         IN             NUMBER
  , x_ret            OUT NOCOPY     NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  , x_context        OUT NOCOPY     NUMBER
  , p_user_id        IN             NUMBER
  ) IS
    l_ret              NUMBER;
    l_msg_data         VARCHAR2(2000);
    l_lpn_id           NUMBER;
    l_dummy            NUMBER;
    l_org_id           NUMBER;
    l_lpn_context      NUMBER;
    l_count            NUMBER;
    l_insp_status      NUMBER;
    l_process_flag_cnt NUMBER;
    l_return_status    VARCHAR2(1)    := fnd_api.g_ret_sts_success;
    l_mo_cnt           NUMBER;
    l_mo_cnt2          NUMBER;
    l_so_cnt           NUMBER;
    l_nested_lpn_cnt   NUMBER;
    l_sub              VARCHAR2(10);
    l_locator_id       NUMBER;
    l_emp_id           NUMBER;--Bug# 3116925
    -- Need to trap the error returned when
    -- unable to lock the lpn record.
    record_locked      EXCEPTION;
    PRAGMA EXCEPTION_INIT(record_locked, -54);
    l_debug            NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    -- Following variables added in ATF_J

    -- end variables added in ATF_J

    l_tempid_tab         num_tab;
    l_error_code         NUMBER;
    l_inspection_flag    NUMBER;
    l_load_flag          NUMBER;
    l_drop_flag          NUMBER;
    l_load_prim_quantity NUMBER;
    l_insp_prim_quantity NUMBER;
    l_drop_prim_quantity NUMBER;
    l_rti_cnt            NUMBER;   --Bug:13613257


    -- This cursor will get the MMTTs assoicated with the LPN passed
    CURSOR c_lpn_mmtt_cursor IS
      SELECT mmtt.transaction_temp_id
      FROM   mtl_material_transactions_temp mmtt
            ,mtl_txn_request_lines mtrl
      WHERE mtrl.line_id = mmtt.move_order_line_id
            AND mtrl.line_status = 7
            AND mtrl.lpn_id = p_lpn_id
            AND mtrl.organization_id = p_org_id;

  BEGIN
    l_lpn_id := p_lpn_id;
    l_org_id := p_org_id;
    x_ret := 0;
    l_count := 0;
    l_process_flag_cnt := 0;

    IF (l_debug = 1) THEN
      mydebug('check_lpn_validity: In LPN Valid APi');
      mydebug('Org' || l_org_id);
      mydebug('check_lpn_validity: LPN' || l_lpn_id);
    END IF;

    --get the context
    BEGIN
       SELECT lpn_context
	 INTO   l_lpn_context
	 FROM   wms_license_plate_numbers
	 WHERE  lpn_id = l_lpn_id
	 AND    organization_id = l_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('check_lpn_validity: LPN does not belong to ' || l_org_id || '  organization');
        END IF;
        fnd_message.set_name('INV', 'INV_NO_RESULT_FOUND');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    mydebug('check_lpn_validity: LPN Context' || l_lpn_context);
    l_mo_cnt := 0;
    l_mo_cnt2 := 0;
    l_so_cnt := 0;
    l_nested_lpn_cnt := 0;

	/*
     Added for the Bug:13613257
    */

    mydebug('check_lpn_validity: Checking is there any non errored RTI for this LPN' || l_lpn_id);

    IF (l_lpn_context = 3) THEN

		BEGIN
          SELECT 1
		  INTO   l_rti_cnt
		  FROM   rcv_transactions_interface
		  WHERE  (transfer_lpn_id  IN (SELECT lpn_id
										FROM   wms_license_plate_numbers
										START  WITH lpn_id = l_lpn_id
										CONNECT BY PRIOR lpn_id = parent_lpn_id)
				  OR lpn_id IN (SELECT lpn_id
										FROM   wms_license_plate_numbers
										START  WITH lpn_id = l_lpn_id
										CONNECT BY PRIOR lpn_id = parent_lpn_id))
		  AND    to_organization_id = l_org_id
		  AND TRANSACTION_STATUS_CODE <> 'ERROR'
		  AND rownum<2;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_rti_cnt := 0;

            IF (l_debug = 1) THEN
              mydebug('check_lpn_validity: RTI not Found');
              mydebug('check_lpn_validity: No pending RTI exist for LPN');
            END IF;

		END;


		IF (l_rti_cnt >0) THEN

		   IF (l_debug = 1) THEN
				  mydebug('check_lpn_validity: RTI  Found Henc cannt putway the LPN');

				END IF;

			fnd_message.set_name('INV', 'INVALID LPN');
			fnd_msg_pub.ADD;
			RAISE fnd_api.g_exc_unexpected_error;
		END IF ;
	END IF ;


    --BUG 3625990: Don't lock if the LPN is in Receiving
    IF (l_lpn_context <> 3) THEN
       -- Lock the LPN or return an error if another user
       -- already has a lock.  This is to prevent the
       -- current session from hanging (bug 1724818).
      BEGIN
	 SELECT     lpn_id
	   INTO       l_dummy
	   FROM       wms_license_plate_numbers
	   WHERE      lpn_id = l_lpn_id
	   AND        organization_id = l_org_id
	   FOR UPDATE NOWAIT;
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    IF (l_debug = 1) THEN
	       mydebug('check_lpn_validity: LPN does not belong to ' || l_org_id || '  organization');
	    END IF;

	    fnd_message.set_name('INV', 'INV_NO_RESULT_FOUND');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_unexpected_error;
	 WHEN record_locked THEN
	    IF (l_debug = 1) THEN
	       mydebug('check_lpn_validity: LPN not available. locked by someone else');
	    END IF;

	    fnd_message.set_name('WMS', 'WMS_LPN_UNAVAIL');
	    fnd_msg_pub.ADD;
	    RAISE fnd_api.g_exc_unexpected_error;
      END;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('check_lpn_validity:  nested LPN Check');
    END IF;

    -- Check to see if this LPN has already been loaded by another user
    -- Check to see if this is a nested LPN
    -- Dont do this check if WMS and PO patch levels are J or higher

    IF l_nested_lpn_cnt > 0 THEN
      IF (l_debug = 1) THEN
        mydebug('check_lpn_validity: This is a nested LPN');
      END IF;

      x_ret := 3;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('check_lpn_validity: This is NOT a nested LPN');
      END IF;

      x_context := l_lpn_context;

      IF (l_lpn_context <> 1) THEN
        IF (l_debug = 1) THEN
          mydebug('check_lpn_validity: Not an inv lpn, so MO has to exist');
        END IF;

        BEGIN
          SELECT 1
          INTO   l_mo_cnt
          FROM   DUAL
          WHERE  EXISTS(SELECT 1
                        FROM   mtl_txn_request_lines
                        WHERE  lpn_id = l_lpn_id
                        AND    organization_id = l_org_id
			);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_mo_cnt := 0;

            IF (l_debug = 1) THEN
              mydebug('check_lpn_validity: MO not Found');
              mydebug('check_lpn_validity: Not an inv lpn and MO does not exist, hence it is invalid');
            END IF;

            x_ret := 3;
        END;

        IF l_mo_cnt > 0 THEN
          /*Check process flag - Flag to indicate processing status for putaways.
          1 means Ok to process,
          2 means Do not Allocate,
          3 means Allocate but do not process.
          To be used by Receiving and WIP*/
          BEGIN
            SELECT 1
            INTO   l_process_flag_cnt
            FROM   DUAL
            WHERE  EXISTS(SELECT 1
                          FROM   mtl_txn_request_lines
                          WHERE  lpn_id = l_lpn_id
                          AND    organization_id = l_org_id
                          AND    NVL(wms_process_flag, 1) = 2
			  AND    line_status <> 5); -- 3773255
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_process_flag_cnt := 0;
          END;

          IF l_process_flag_cnt > 0 THEN
            x_ret := 2;

            IF (l_debug = 1) THEN
              mydebug('check_lpn_validity: wms_process_flag does not allow allocations/putaway');
            END IF;
          ELSE
            l_count := 0;

            IF (l_debug = 1) THEN
              mydebug('check_lpn_validity: wms_process_flag allows allocations/putaway');
            END IF;


      -- Calling the ATF API Validate to check whether inspection is required or not.
      -- If MMTT is available for the LPN (pre-generate or in middle of operation cases)
      -- call validate_operation by passing the MMTT ID
      -- Else call validate_operation by passing the LPN ID

       OPEN c_lpn_mmtt_cursor;

       FETCH c_lpn_mmtt_cursor
         BULK COLLECT
          INTO l_tempid_tab;

       -- MMTT records exist check
       IF l_tempid_tab.COUNT > 0 THEN
	  -- The LPN passed has MMTT records so call validate_operation

	  -- Validate each MMTT record
	  FOR i IN 1 .. l_tempid_tab.COUNT LOOP

	     wms_atf_runtime_pub_apis.validate_operation (
                x_return_status    =>   x_return_status
               ,x_msg_data         =>   x_msg_data
               ,x_msg_count        =>   x_msg_count
               ,x_error_code       =>   l_error_code
               ,x_inspection_flag  =>   l_inspection_flag
               ,x_load_flag        =>   l_load_flag
               ,x_drop_flag        =>   l_drop_flag
               ,x_load_prim_quantity    => l_load_prim_quantity
               ,x_drop_prim_quantity    => l_drop_prim_quantity
               ,x_inspect_prim_quantity => l_insp_prim_quantity
               ,p_source_task_id        => l_tempid_tab(i)
               ,p_move_order_line_id    => NULL
               ,p_inventory_item_id     => NULL
               ,p_lpn_id                => NULL
               ,p_activity_type_id      => G_OP_ACTIVITY_INBOUND
               ,p_organization_id       => p_org_id
              );

            IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
               IF (l_debug = 1) THEN
                  mydebug('Check LPN Validity: validate_operation failed ' || x_msg_data );
               END IF;
               RAISE fnd_api.g_exc_error;
            END IF;

	    -- Bug# 3349802
	    -- The variable l_count is initialized to 0 previously.  For
	    -- each MMTT record validated, if it requires inspection, then
	    -- add 1 to l_count.  Once we are done looping through all MMTT
	    -- records, if l_count = 0 then that means all MMTT records do
	    -- not require inspection.  If l_count = l_tempid_tab.COUNT, then
	    -- all MMTT records require inspection.  Otherwise some of the
	    -- MMTT records require inspection.  We do not want to exit the
	    -- validation loop if one of the MMTT records require
	    -- inspection.  Otherwise there would be no way to determine if
	    -- partial inspection or full inspection is required for the LPN.
            IF (l_inspection_flag <> G_NO_INSPECTION) THEN
               -- This MMTT requires inspection
               mydebug('MMTT:'||l_tempid_tab(i)||' Requires inspection');

               -- Increment l_count by 1
               l_count := l_count + 1;
            END IF;

         END LOOP; -- Finished validating each MMTT record for the given LPN

	 -- Check the value for l_count to determine what type of
	 -- inspection is required for the LPN.  Also set the value
	 -- of l_count to the appropriate value as before.
	 IF (l_count = l_tempid_tab.COUNT) THEN
	    l_count := 1;
	    mydebug('All of the MMTT records require inspection');
	  ELSIF (l_count = 0) THEN
	    l_count := 0;
	    mydebug('None of the MMTT records require inspection');
	  ELSE
	    l_count := 0;
	    x_ret := 4;
	    mydebug('Some of the MMTT records require inspection');
	 END IF;

	ELSE
         -- The LPN passed does not have MMTTs so call validate_operation by passing LPN ID

         wms_atf_runtime_pub_apis.validate_operation (
             x_return_status    =>   x_return_status
            ,x_msg_data         =>   x_msg_data
            ,x_msg_count        =>   x_msg_count
            ,x_error_code       =>   l_error_code
            ,x_inspection_flag  =>   l_inspection_flag
            ,x_load_flag        =>   l_load_flag
            ,x_drop_flag        =>   l_drop_flag
            ,x_load_prim_quantity    => l_load_prim_quantity
            ,x_drop_prim_quantity    => l_drop_prim_quantity
            ,x_inspect_prim_quantity => l_insp_prim_quantity
            ,p_source_task_id        => NULL
            ,p_move_order_line_id    => NULL
            ,p_inventory_item_id     => NULL
            ,p_lpn_id                => p_lpn_id
            ,p_activity_type_id      => G_OP_ACTIVITY_INBOUND
            ,p_organization_id       => p_org_id
           );

         IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
               mydebug('Check LPN Validty:validate_operation failed ' || x_msg_data );
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;

	 IF (l_inspection_flag = g_partial_inspection) THEN
	    mydebug('LPN: '|| p_lpn_id||' is partially inspected');
	    l_count := 0;
	    x_ret := 4;
	  ELSIF (l_inspection_flag <> G_NO_INSPECTION) THEN
            -- This MMTT requires inspection, hence set the inspect req flag and exit out of the loop
            mydebug('LPN: '|| p_lpn_id||' Requires inspection. hence set the ret status to inspect required');
            -- Setting the flag which will indicate inspect is req
            l_count := 1;
         END IF;

       END IF; -- MMTTS exists check



            IF l_count > 0 THEN
              IF (l_debug = 1) THEN
                mydebug('check_lpn_validity: LPN Needs inspection');
              END IF;

              x_ret := 1;
            END IF;
          END IF;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('check_lpn_validity: It is an INV LPN');
          mydebug('check_lpn_validity: Verifying that this LPN has not been picked for any sales order');
        END IF;

        BEGIN
          SELECT 1
          INTO   l_so_cnt
          FROM   DUAL
          WHERE  EXISTS(
                   SELECT 1
                   FROM   wsh_delivery_details_ob_grp_v wdd, wsh_delivery_assignments_v wda
                   WHERE  wdd.lpn_id = l_lpn_id
		   AND    wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
                   AND    wdd.organization_id = l_org_id
                   AND    wdd.delivery_detail_id = wda.parent_delivery_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_so_cnt := 0;
        END;

        IF l_so_cnt > 0 THEN
          IF (l_debug = 1) THEN
            mydebug('check_lpn_validity: LPN has been picked for a sales order and hence cannot be putaway');
          END IF;

          x_ret := 3;
        END IF;

        -- Fix for Bug No. : 2374961
        -- Since we are now commiting after detailing for an
        -- INV LPN (in suggestions_pub), we have to check to see if
        -- move orders exist
        -- if they do, it implies that somebody else is attempting to
        -- putaway the LPN

        IF (l_debug = 1) THEN
          mydebug('check_lpn_validity: Verifying that this LPN is not in use');
        END IF;

        --Checking whether this LPN is being processed by somebody else.

        --Bug# 3116925
        --Get the employee ID so we can use it
        --for checking against the person_id column in WDT
        --because while creating the task, employee_id is stored.
        BEGIN
          SELECT employee_id
          INTO l_emp_id
          FROM fnd_user
          WHERE user_id = p_user_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
      IF (l_debug = 1) THEN
        mydebug('Check_LPN_Validity: There is no employee tied to the user');
      END IF;
    l_emp_id := NULL;
        END;

        IF (l_debug = 1) THEN
     mydebug('Check_LPN_Validity:  Emp Id ' || l_emp_id );
        END IF;

        BEGIN
          SELECT 1
          INTO   l_mo_cnt2
          FROM   DUAL
          WHERE  EXISTS(
                   SELECT 1
                   FROM   wms_dispatched_tasks wdt
                        , mtl_material_transactions_temp mmtt
                        , mtl_txn_request_lines mtrl
                   WHERE  mtrl.lpn_id = l_lpn_id
                   AND    mtrl.organization_id = l_org_id
                   AND    mtrl.line_id = mmtt.move_order_line_id
                   AND    wdt.transaction_temp_id = mmtt.transaction_temp_id
                   AND    wdt.status <> 4
                   AND NOT (wdt.status = 3 AND wdt.person_id = l_emp_id ));--Bug# 3116925
                  -- AND    NOT(wdt.status = 3
                  --            AND wdt.person_id = p_user_id));
        /*
        SELECT 1 INTO l_mo_cnt2 FROM DUAL WHERE  exists
          (SELECT 1
           FROM mtl_txn_request_lines mol,
           mtl_material_transactions_temp mmtt
           , wms_dispatched_tasks wdt
           WHERE mol.lpn_id=l_lpn_id
           AND mol.organization_id=l_org_id
           AND mol.line_id=mmtt.move_order_line_id
           AND wdt.transaction_temp_id=mmtt.transaction_temp_id
          );
          */
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_mo_cnt2 := 0;
        END;

        IF l_mo_cnt2 > 0 THEN
          IF (l_debug = 1) THEN
            mydebug('check_lpn_validity: LPN is being processed by somebody else and hence cannot be putaway');
          END IF;

          x_ret := 3;
          fnd_message.set_name('WMS', 'WMS_LPN_UNAVAIL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('check_lpn_validity: Ret Status' || l_return_status);
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END check_lpn_validity;

  PROCEDURE archive_task(
    p_temp_id        IN             NUMBER
  , p_org_id         IN             NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  ) IS
    l_temp_id               NUMBER;
    l_txn_header_id         NUMBER;
    l_org_id                NUMBER;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_mmtt_line_id          NUMBER;
    l_mmtt_qty              NUMBER;
    l_transaction_batch_id  NUMBER;
    l_transaction_batch_seq NUMBER;
    l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('In archive task..' || p_temp_id || ':' || p_org_id);
    END IF;

    l_temp_id := p_temp_id;
    l_org_id := p_org_id;

    IF (l_debug = 1) THEN
      mydebug('Get relevant info..');
    END IF;

    SELECT move_order_line_id
         , transaction_quantity
         , transaction_header_id
         , transaction_batch_id
         , transaction_batch_seq
    INTO   l_mmtt_line_id
         , l_mmtt_qty
         , l_txn_header_id
         , l_transaction_batch_id
         , l_transaction_batch_seq
    FROM   mtl_material_transactions_temp
    WHERE  transaction_temp_id = l_temp_id
    AND    organization_id = l_org_id;

    IF (l_debug = 1) THEN
      mydebug('Line id' || l_mmtt_line_id);
      mydebug('temp id' || l_temp_id);
    END IF;

    -- Insert into WMS_DISPATCHED_TASKS_HISTORY with a status of 6, 'complete'

    l_return_status := fnd_api.g_ret_sts_success;
    wms_insert_wdth_pvt.insert_into_wdth
      ( x_return_status         => l_return_status
	, p_txn_header_id         => l_txn_header_id
	, p_transaction_temp_id   => l_temp_id
	, p_transaction_batch_id  => l_transaction_batch_id
	, p_transaction_batch_seq => l_transaction_batch_seq
	, p_transfer_lpn_id       => NULL
	);

    IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
       IF l_debug = 1 THEN
	  mydebug ('Error from wms_insert_wdth_pvt.insert_into_wdth');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_debug = 1) THEN
      mydebug('After wmsdt update');
    END IF;

    -- Delete this row from wms_dispatched_tasks
    DELETE      wms_dispatched_tasks
          WHERE transaction_temp_id = l_temp_id;

    -- Delete lot and serial records
    BEGIN
      DELETE mtl_serial_numbers_temp
      WHERE  transaction_temp_id = (SELECT serial_transaction_temp_id
                                    FROM   mtl_transaction_lots_temp
                                    WHERE  transaction_temp_id = l_temp_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    BEGIN
      DELETE mtl_transaction_lots_temp
      WHERE  transaction_temp_id = l_temp_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    BEGIN
      DELETE mtl_serial_numbers_temp
      WHERE  transaction_temp_id = l_temp_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    -- Delete this row from mmtt
    DELETE mtl_material_transactions_temp
    WHERE  transaction_temp_id = l_temp_id;

    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('done WITH API');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_TD_AT_FAIL');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END archive_task;

  PROCEDURE archive_task(
    p_temp_id           IN             NUMBER
  , p_org_id            IN             NUMBER
  , x_return_status     OUT NOCOPY     VARCHAR2
  , x_msg_count         OUT NOCOPY     NUMBER
  , x_msg_data          OUT NOCOPY     VARCHAR2
  , p_delete_mmtt_flag  IN             VARCHAR2
  , p_txn_header_id     IN             NUMBER
  , p_transfer_lpn_id   IN             NUMBER DEFAULT NULL
  ) IS
    l_temp_id               NUMBER;
    l_org_id                NUMBER;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_transaction_batch_id  NUMBER;
    l_transaction_batch_seq NUMBER;
    l_debug                 NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('archive_task: In archive task..' || p_temp_id || ':' || p_org_id);
    END IF;

    l_temp_id := p_temp_id;
    l_org_id := p_org_id;
    l_return_status := fnd_api.g_ret_sts_success;


    /* Bug 3961107-Modified the query to select transaction_batch_id and transaction_batch_seq
       as null if they have null values in the table.
    SELECT NVL(transaction_batch_id, -999)
         , NVL(transaction_batch_seq, -999)*/
    SELECT transaction_batch_id,
           transaction_batch_seq
    --End of fix for Bug 3961107
    INTO   l_transaction_batch_id
         , l_transaction_batch_seq
    FROM   mtl_material_transactions_temp
    WHERE  transaction_temp_id = l_temp_id
    AND    organization_id = l_org_id;

    IF (l_debug = 1) THEN
      mydebug('Temp ID: ' || l_temp_id);
      mydebug('Batch ID: ' || l_transaction_batch_id);
      mydebug('Batch Seq: ' || l_transaction_batch_seq);
    END IF;

    -- Insert into WMS_DISPATCHED_TASKS_HISTORY with a status of 6, 'complete'

    l_return_status := fnd_api.g_ret_sts_success;
    wms_insert_wdth_pvt.insert_into_wdth
      ( x_return_status         => l_return_status
	, p_txn_header_id         => p_txn_header_id
	, p_transaction_temp_id   => l_temp_id
	, p_transaction_batch_id  => l_transaction_batch_id
	, p_transaction_batch_seq => l_transaction_batch_seq
	, p_transfer_lpn_id       => p_transfer_lpn_id
	);

    IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
       IF l_debug = 1 THEN
	  mydebug ('Error from wms_insert_wdth_pvt.insert_into_wdth');
       END IF;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Delete this row from wms_dispatched_tasks
    DELETE FROM wms_dispatched_tasks
          WHERE transaction_temp_id = l_temp_id;

    IF (l_debug = 1) THEN
      mydebug('archive_task: After wmsdt update');
    END IF;

    IF p_delete_mmtt_flag = 'Y' THEN
      -- Delete lot and serial records
      BEGIN
        DELETE mtl_serial_numbers_temp
        WHERE  transaction_temp_id IN
          (SELECT serial_transaction_temp_id
           FROM   mtl_transaction_lots_temp
           WHERE  transaction_temp_id = l_temp_id);
      EXCEPTION
        WHEN OTHERS THEN
          mydebug('archive_task: Error deleting MSNT for MTLT: ' || sqlerrm);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      BEGIN
        DELETE  mtl_transaction_lots_temp
        WHERE   transaction_temp_id = l_temp_id;
      EXCEPTION
        WHEN OTHERS THEN
          mydebug('archive_task: Error deleting MTLT: ' || sqlerrm);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      BEGIN
        DELETE  mtl_serial_numbers_temp
        WHERE   transaction_temp_id = l_temp_id;
      EXCEPTION
        WHEN OTHERS THEN
          mydebug('archive_task: Error deleting MSNT: ' || sqlerrm);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      BEGIN
        DELETE  mtl_material_transactions_temp
        WHERE   transaction_temp_id = l_temp_id;
      EXCEPTION
        WHEN OTHERS THEN
          mydebug('archive_task: Error deleting MMTT: ' || sqlerrm);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('archive_task: done WITH API');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
         mydebug('Other exception occurred: ' || sqlerrm);
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_TD_AT_FAIL');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END archive_task;

  PROCEDURE putaway_cleanup(
    p_temp_id        IN             NUMBER
  , p_org_id         IN             NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  ) IS
    l_temp_id                 NUMBER;
    l_txn_header_id           NUMBER;
    l_org_id                  NUMBER;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    l_mmtt_line_id            NUMBER;
    l_mmtt_qty                NUMBER;
    l_item_id                 NUMBER;
    l_person_id               NUMBER;
    l_loc_id                  NUMBER;
    l_sub                     VARCHAR2(10);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot                     VARCHAR2(80);
    l_rev                     VARCHAR2(3);
    l_last_updated_by         NUMBER;
    l_sequence                NUMBER;
    cnt                       NUMBER         := 0;
    l_back_id                 NUMBER         := 0;
    l_crdk_type               NUMBER         := 0;
    l_demand_source_header_id NUMBER         := -1;
    l_repetitive_line_id      NUMBER         := -1;
    l_operation_seq_num       NUMBER         := -1;
    l_primary_qty             NUMBER         := -1;
    l_debug                   NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    -- Following variables added in ATF_J4


    l_secondary_quantity  NUMBER; --OPM Convergence
    -- End variables added in ATF_J4

    -- Bug# 3281512 - Performance Fixes
    -- Add cursor to get serial_transaction_temp_id values for performance.
    -- SQL compiler complains of a Hash Join otherwise.
    CURSOR c_serial_transaction_temp_id IS
       SELECT serial_transaction_temp_id
	 FROM mtl_transaction_lots_temp
	 WHERE transaction_temp_id = l_temp_id;
    l_serial_transaction_temp_id   NUMBER;
    -- Bug# 3434940 - Performance Fixes
    -- Add cursor to get the serial number(s) for a given MSNT record.
    -- SQL compiler complains of a Hash Join otherwise.
    CURSOR c_serial_number(v_transaction_temp_id NUMBER) IS
       SELECT fm_serial_number
	 FROM   mtl_serial_numbers_temp
	 WHERE  transaction_temp_id = v_transaction_temp_id;
    l_fm_serial_number NUMBER;

  BEGIN
    IF (l_debug = 1) THEN
      mydebug('In putaway cleanup..');
    END IF;

    l_temp_id := p_temp_id;
    l_org_id := p_org_id;
    l_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('Get relevant info..');
    END IF;

    SELECT t.move_order_line_id
         , t.transaction_quantity
         , t.inventory_item_id
         , t.primary_quantity
         , w.person_id
         , t.locator_id
         , t.subinventory_code
         , t.lot_number
         , t.revision
         , t.last_updated_by
         , t.demand_source_header_id
         , t.repetitive_line_id
         , t.operation_seq_num
         , t.secondary_transaction_quantity  --OPM Convergence
    INTO   l_mmtt_line_id
         , l_mmtt_qty
         , l_item_id
         , l_primary_qty
         , l_person_id
         , l_loc_id
         , l_sub
         , l_lot
         , l_rev
         , l_last_updated_by
         , l_demand_source_header_id
         , l_repetitive_line_id
         , l_operation_seq_num
         , l_secondary_quantity --OPM Convergence
    FROM   mtl_material_transactions_temp t, wms_dispatched_tasks w
    WHERE  t.transaction_temp_id = l_temp_id
    AND    t.organization_id = l_org_id
    AND    t.transaction_temp_id = w.transaction_temp_id;

    IF (l_debug = 1) THEN
      mydebug('Line id' || l_mmtt_line_id);
    END IF;

    -- Log exception

    --Calculate Sequence Number
    SELECT wms_exceptions_s.NEXTVAL
    INTO   l_sequence
    FROM   DUAL;

    IF (l_debug = 1) THEN
      mydebug('Inserting into exceptions');
      mydebug(l_sequence);
    END IF;

    INSERT INTO wms_exceptions
                (
                 task_id
               , sequence_number
               , organization_id
               , inventory_item_id
               , person_id
               , effective_start_date
               , effective_end_date
               , inventory_location_id
               , reason_id
               , discrepancy_type
               , subinventory_code
               , lot_number
               , revision
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
                )
    VALUES      (
                 l_temp_id
               , l_sequence
               , l_org_id
               , l_item_id
               , l_person_id
               , SYSDATE
               , SYSDATE
               , l_loc_id
               , -999
               , 2
               , l_sub
               , l_lot
               , l_rev
               , SYSDATE
               , l_last_updated_by
               , SYSDATE
               , l_last_updated_by
                );

    -- ATF_J4
    -- If current release is J or above, do not
    -- update move order line, delete MMTT and revert crossdocking.
    -- Because cleanup can happen at an operation in the middle of
    -- an operation plan.
    -- If MMTT is not tied to an active operation plan,
    -- delete MMTT and update move order line will happen in suggestions_PUB;
    -- Not reverting crossdocking is probably not optimal, but safe.


  -- Cleanup the serials before Deleting MMTT
    IF (l_debug = 1) THEN
      mydebug('Updating Group_mark_id for Serials ');
    END IF;

    -- Update for Lot/Serial controlled item
    -- Bug# 3281512 - Performance Fixes
    -- Use the c_serial_transaction_temp_id cursor to avoid the hash join.
    -- Also match against MSN using the item and the org to use the indexes more efficiently.
    -- Bug# 3434940 - Performance Fixes
    -- Also create and use another cursor, c_serial_number to avoid the
    -- hash join.  This cursor will loop through the serials in MSNT for
    -- the given transaction temp id.
    OPEN c_serial_transaction_temp_id;
    LOOP
       FETCH c_serial_transaction_temp_id INTO l_serial_transaction_temp_id;
       EXIT WHEN c_serial_transaction_temp_id%NOTFOUND;

       OPEN c_serial_number(l_serial_transaction_temp_id);
       LOOP
	  FETCH c_serial_number INTO l_fm_serial_number;
	  EXIT WHEN c_serial_number%NOTFOUND;

	  UPDATE mtl_serial_numbers
	    SET    group_mark_id = NULL
	    WHERE  serial_number = l_fm_serial_number
	    AND    inventory_item_id = l_item_id
	    AND    current_organization_id = l_org_id;

       END LOOP;
       CLOSE c_serial_number;

    END LOOP;
    CLOSE c_serial_transaction_temp_id;

    -- Update for Serial controlled item
    -- Bug# 3281512 - Performance Fixes
    -- Match against MSN using the item and org to use the indexes more efficiently.
    -- Bug# 3434940 - Performance Fixes
    -- Also create and use another cursor, c_serial_number to avoid the
    -- hash join.  This cursor will loop through the serials in MSNT for
    -- the given transaction temp id.
    OPEN c_serial_number(l_temp_id);
    LOOP
       FETCH c_serial_number INTO l_fm_serial_number;
       EXIT WHEN c_serial_number%NOTFOUND;

       UPDATE mtl_serial_numbers
	 SET    group_mark_id = NULL
	 WHERE  serial_number = l_fm_serial_number
	 AND    inventory_item_id = l_item_id
	 AND    current_organization_id = l_org_id;

    END LOOP;
    CLOSE c_serial_number;

    -- Bug 2458540
    -- Reset the Status Back if putaway fails
    -- For cases with RMA and serial at sales order Issue

    -- Update for Lot/Serial controlled item
    -- Bug# 3281512 - Performance Fixes
    -- Use the cursor to avoid the hash join.  Also match against MSN using
    -- the org to use the indexes more efficiently.
    -- Bug# 3434940 - Performance Fixes
    -- Also create and use another cursor, c_serial_number to avoid the
    -- hash join.  This cursor will loop through the serials in MSNT for
    -- the given transaction temp id.
    OPEN c_serial_transaction_temp_id;
    LOOP
       FETCH c_serial_transaction_temp_id INTO l_serial_transaction_temp_id;
       EXIT WHEN c_serial_transaction_temp_id%NOTFOUND;

       OPEN c_serial_number(l_serial_transaction_temp_id);
       LOOP
	  FETCH c_serial_number INTO l_fm_serial_number;
	  EXIT WHEN c_serial_number%NOTFOUND;

	  UPDATE mtl_serial_numbers
	    SET    current_status = 5,
  	           previous_status = NULL
	    WHERE  serial_number = l_fm_serial_number
	    AND    inventory_item_id = l_item_id
	    AND    lot_number = l_lot
	    AND    current_status = 4
	    AND    current_organization_id = l_org_id
	    AND    EXISTS (SELECT 1
			   FROM   mtl_txn_request_lines mol
			   WHERE  mol.line_id = l_mmtt_line_id
			   AND    mol.REFERENCE = 'ORDER_LINE_ID');
       END LOOP;
       CLOSE c_serial_number;

    END LOOP;
    CLOSE c_serial_transaction_temp_id;

    -- Update for Serial controlled item
    -- Bug# 3281512 - Performance Fixes
    -- Match against MSN using the item and org to use the indexes more efficiently.
    -- Bug# 3434940 - Performance Fixes
    -- Also create and use another cursor, c_serial_number to avoid the
    -- hash join.  This cursor will loop through the serials in MSNT for
    -- the given transaction temp id.
    OPEN c_serial_number(l_temp_id);
    LOOP
       FETCH c_serial_number INTO l_fm_serial_number;
       EXIT WHEN c_serial_number%NOTFOUND;

       UPDATE mtl_serial_numbers
	 SET current_status = 5,
	     previous_status = NULL
	 WHERE  serial_number = l_fm_serial_number
	 AND    inventory_item_id = l_item_id
	 AND    current_status = 4
	 AND    current_organization_id = l_org_id
	 AND    EXISTS (SELECT 1
			FROM   mtl_txn_request_lines mol
			WHERE  mol.line_id = l_mmtt_line_id
			AND    mol.REFERENCE = 'ORDER_LINE_ID');
    END LOOP;
    CLOSE c_serial_number;


    x_return_status := l_return_status;

    --x_return_status:=FND_API.G_RET_STS_SUCCESS;
    IF (l_debug = 1) THEN
      mydebug('done WITH API');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_TD_PUT_CLEAN_FAIL');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END putaway_cleanup;

  PROCEDURE validate_putaway_to_lpn(
    p_org_id         IN             NUMBER
  , p_to_lpn         IN             VARCHAR2
  , p_from_lpn       IN             VARCHAR2
  , p_sub            IN             VARCHAR2
  , p_loc_id         IN             NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  , x_return         OUT NOCOPY     NUMBER
  , p_crossdock      IN             VARCHAR2 DEFAULT NULL
  ) IS
    l_count       NUMBER;
    l_to_lpn_id   NUMBER;
    l_lpn_context NUMBER;
    l_quantity    NUMBER;
    l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    -- Bug 4411792
    l_lpn_update  WMS_CONTAINER_PUB.LPN;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);


  BEGIN
    IF (l_debug = 1) THEN
      mydebug('validate_putaway_to_lpn : validate_putaway_to_lpn Entered');
    END IF;

    x_return := 0;
    l_count := 0;
    x_return_status := fnd_api.g_ret_sts_success;

    BEGIN
      SELECT 1
           , lpn_id
      INTO   l_count
           , l_to_lpn_id
      FROM   wms_license_plate_numbers wlpn
      WHERE  wlpn.license_plate_number = p_to_lpn
      AND    wlpn.organization_id = p_org_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_count := 0;
    END;

    IF l_count = 0 THEN
      -- New LPN
      IF (l_debug = 1) THEN
        mydebug('validate_putaway_to_lpn : LPN does not exist. Create new LPN');
      END IF;

      wms_task_dispatch_gen.create_lpn(
        p_organization_id     => p_org_id
      , p_lpn                 => p_to_lpn
      , p_lpn_id              => l_to_lpn_id
      , x_return_status       => x_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      );

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        fnd_message.set_name('WMS', 'WMS_TD_CREATE_LPN_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      x_return := 1;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('validate_putaway_to_lpn : LPN already exists. Check to see if the LPN resides in the sub/loc');
        mydebug('From LPN ID: ' || p_from_lpn || ' To LPN ID: ' || p_to_lpn);
      END IF;

      -- Check from LPN and to LPN match
      -- bug fix 2271470

      IF p_from_lpn <> p_to_lpn THEN
        -- Bug Fix 2505636
        IF p_crossdock = 'Y' THEN
          IF (l_debug = 1) THEN
            mydebug('LPN crossdocked and from and to lpn different');
          END IF;

          BEGIN
            -- Check the LPN Content it should be null
            SELECT quantity
            INTO   l_quantity
            FROM   wms_lpn_contents
            WHERE  parent_lpn_id = l_to_lpn_id
            AND    ROWNUM < 2;

            --
            IF l_quantity >= 0 THEN
              IF (l_debug = 1) THEN
                mydebug('LPN has contents so can not putaway');
              END IF;

              x_return := 0;
              RETURN;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (l_debug = 1) THEN
                mydebug('LPN has no contents so should be OK to putaway');
              END IF;
          END;
        END IF;

        l_count := 0;

        BEGIN
          SELECT 1
          INTO   l_count
          FROM   DUAL
          WHERE  EXISTS(
                   SELECT 1
                   FROM   mtl_material_transactions_temp mmtt
                   WHERE  (
                           NVL(mmtt.subinventory_code, '@') <> NVL(p_sub, NVL(mmtt.subinventory_code, '@'))
                           OR NVL(mmtt.locator_id, '0') <> NVL(p_loc_id, NVL(mmtt.locator_id, '0'))
                          )
                   AND    mmtt.organization_id = p_org_id
                   AND    mmtt.transaction_status = 3
                   AND    mmtt.transfer_lpn_id = l_to_lpn_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count := 0;
        END;

        IF l_count > 0 THEN
          x_return := 0;

          IF (l_debug = 1) THEN
            mydebug('validate_putaway_to_lpn: LPN has a pending transaction going to different location');
          END IF;

          RETURN;
        END IF;

        IF (l_debug = 1) THEN
          mydebug('p_org_id : ' || p_org_id);
          mydebug('p_to_lpn : ' || p_to_lpn);
          mydebug('p_sub : ' || p_sub);
          mydebug('p_loc_id : ' || p_loc_id);
          mydebug('p_from_lpn : ' || p_from_lpn);
        END IF;

        BEGIN
          SELECT 1
          INTO   l_count
          FROM   DUAL
          WHERE  EXISTS(
                   SELECT 1
                   FROM   wms_license_plate_numbers wlpn
                   WHERE  wlpn.organization_id = p_org_id
                   AND    license_plate_number = p_to_lpn
                   AND    (
                           wlpn.lpn_context = 5
                           OR(wlpn.lpn_context = 1
                              AND wlpn.subinventory_code IS NULL
                              AND wlpn.locator_id IS NULL)
                           OR(
                              wlpn.lpn_context = 1
                              AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
                              AND NVL(wlpn.locator_id, '0') = NVL(p_loc_id, NVL(wlpn.locator_id, '0'))
                              AND NOT wlpn.license_plate_number = NVL(p_from_lpn, -999)
                              AND inv_material_status_grp.is_status_applicable(
                                   'TRUE'
                                 , NULL
                                 , inv_globals.g_type_container_pack
                                 , NULL
                                 , NULL
                                 , p_org_id
                                 , NULL
                                 , wlpn.subinventory_code
                                 , wlpn.locator_id
                                 , NULL
                                 , NULL
                                 , 'Z'
                                 ) = 'Y'
                              AND inv_material_status_grp.is_status_applicable(
                                   'TRUE'
                                 , NULL
                                 , inv_globals.g_type_container_pack
                                 , NULL
                                 , NULL
                                 , p_org_id
                                 , NULL
                                 , wlpn.subinventory_code
                                 , wlpn.locator_id
                                 , NULL
                                 , NULL
                                 , 'L'
                                 ) = 'Y'
                             )
                          ));
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count := 0;

            IF (l_debug = 1) THEN
              mydebug('validate_putaway_to_lpn: No data found');
            END IF;
        END;

        IF l_count > 0 THEN
          x_return := 1;

          IF (l_debug = 1) THEN
            mydebug('validate_putaway_to_lpn: LPN exists in the sub/loc or is defined but not used');
          END IF;
        ELSE
          x_return := 0;

          IF (l_debug = 1) THEN
            mydebug('validate_putaway_to_lpn: LPN does not exist in the sub/loc');
          END IF;
        END IF;
      -- bug fix 2271470
      ELSE -- p_from_lpn = p_to_lpn
        BEGIN
          SELECT COUNT(1)
          INTO   l_count
          FROM   mtl_txn_request_lines mol
          WHERE  mol.lpn_id = l_to_lpn_id
          AND    mol.line_status <> inv_globals.g_to_status_closed
          AND    (
                  (mol.quantity - NVL(mol.quantity_delivered, 0)) > (SELECT SUM(mmtt.transaction_quantity)
                                                                     FROM   mtl_material_transactions_temp mmtt
                                                                     WHERE  mmtt.move_order_line_id = mol.line_id)
                  OR(mol.quantity - NVL(mol.quantity_delivered, 0) > 0
                     AND NOT EXISTS(SELECT 1
                                    FROM   mtl_material_transactions_temp mmtt
                                    WHERE  mmtt.move_order_line_id = mol.line_id))
                 );

          IF (l_debug = 1) THEN
            mydebug('l_count = ' || l_count);
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count := 0;
        END;

        IF l_count > 0 THEN
          x_return := 0;

          IF (l_debug = 1) THEN
            mydebug(
              'Validate_putaway_to_lpn: LPN has a pending transaction with quantity less then the difference between total quantity on MOL and quantity delivered. Cannot putaway this LPN.'
            );
          END IF;

          RETURN;
        ELSE
          x_return := 1;
          RETURN;
        END IF;
      END IF;
    END IF;

    SELECT wlc.lpn_context
    INTO   l_lpn_context
    FROM   wms_license_plate_numbers wlc
    WHERE  wlc.license_plate_number = p_to_lpn
    AND    wlc.organization_id = p_org_id;

    IF (l_debug = 1) THEN
      mydebug('lpn_context = ' || l_lpn_context);
    END IF;

    IF l_lpn_context = wms_container_pub.lpn_context_pregenerated THEN
      IF (l_debug = 1) THEN
        mydebug('update LPN context to 1');
      END IF;

      -- Bug 4411792
      l_lpn_update.license_plate_number      :=  p_to_lpn;
      l_lpn_update.organization_id           :=  p_org_id;
      l_lpn_update.lpn_context               := wms_container_pub.lpn_context_inv;

      wms_container_pvt.Modify_LPN
             (
               p_api_version             => 1.0
               , p_validation_level      => fnd_api.g_valid_level_none
               , x_return_status         => l_return_status
               , x_msg_count             => l_msg_count
               , x_msg_data              => l_msg_data
               , p_lpn                   => l_lpn_update
      ) ;

      l_lpn_update := NULL;

      -- 4411792 The below is replaced by the above API call
      --UPDATE wms_license_plate_numbers
      --SET lpn_context = wms_container_pub.lpn_context_inv
      --WHERE  license_plate_number = p_to_lpn
      --AND    organization_id = p_org_id;

    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('validate_putaway_to_lpn : Exception : ' || SQLERRM);
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END validate_putaway_to_lpn;

  /* This API will check the status of the mmtt lines
   This will be called from the suggestions_api, as part of the putaway
     process We need to do this at the mmtt line level rather than just
     checking the lpn contents because the transaction type id might differ
     in each MOL. Returns x_mtl_stat 0 if everything is fine, 1 otherwise*/
  PROCEDURE check_mmtt_mtl_status(
    p_temp_id        IN             VARCHAR2
  , p_org_id         IN             NUMBER
  , x_mtl_status     OUT NOCOPY     NUMBER
  , x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  ) IS
    l_temp_id          NUMBER;
    l_org_id           NUMBER;
    l_serial_temp_id   NUMBER;
    l_txn_type_id      NUMBER;
    l_ser_control_code NUMBER;
    l_lot_control_code NUMBER;
    l_item_id          NUMBER;
    l_serial_number    VARCHAR2(30);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number       VARCHAR2(80);
    l_sub              VARCHAR2(30);
    l_loc              NUMBER;
    l_lpn_id           NUMBER;

    CURSOR lot_csr IS
      SELECT lot_number
           , serial_transaction_temp_id
      FROM   mtl_transaction_lots_temp
      WHERE  transaction_temp_id = l_temp_id;

    CURSOR ser_csr IS
      SELECT serial_number
      FROM   mtl_serial_numbers
      WHERE  lpn_id = l_lpn_id
      AND    inventory_item_id = l_item_id
      AND    current_organization_id = l_org_id
      AND    NVL(lot_number, -999) = NVL(l_lot_number, -999);

    l_debug            NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('in check_mmtt_mtl_status api');
      mydebug('p_temp_id => ' || p_temp_id);
      mydebug('p_org_id => ' || p_org_id);
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    x_mtl_status := 0;
    l_temp_id := p_temp_id;
    l_org_id := p_org_id;
    l_lot_number := NULL;

    SELECT msi.lot_control_code
         , msi.serial_number_control_code
         , mmtt.transaction_type_id
         , mmtt.inventory_item_id
         , DECODE(mmtt.transaction_action_id, 2, mmtt.transfer_subinventory, subinventory_code) sub
         , DECODE(mmtt.transaction_action_id, 2, mmtt.transfer_to_location, locator_id)
         , lpn_id
    INTO   l_lot_control_code
         , l_ser_control_code
         , l_txn_type_id
         , l_item_id
         , l_sub
         , l_loc
         , l_lpn_id
    FROM   mtl_system_items msi, mtl_material_transactions_temp mmtt
    WHERE  mmtt.organization_id = l_org_id
    AND    mmtt.transaction_temp_id = l_temp_id
    AND    msi.organization_id = mmtt.organization_id
    AND    msi.inventory_item_id = mmtt.inventory_item_id;

    IF (l_debug = 1) THEN
      mydebug('check_mmtt_mtl_status: After getting relevant info..');
      mydebug('check_mmtt_mtl_status: Lot Code: ' || l_lot_control_code);
      mydebug('check_mmtt_mtl_status: Ser Code: ' || l_ser_control_code);
      mydebug('check_mmtt_mtl_status: Tran Type ID: ' || l_txn_type_id);
      mydebug('check_mmtt_mtl_status: Item: ' || l_item_id);
    END IF;

    IF l_lot_control_code > 1 THEN
      IF (l_debug = 1) THEN
        mydebug('check_mmtt_mtl_status: Lot controlled');
      END IF;

      -- lot controlled - CHECK lot status
      OPEN lot_csr;

      LOOP
        FETCH lot_csr INTO l_lot_number, l_serial_temp_id;
        EXIT WHEN lot_csr%NOTFOUND;

        IF l_ser_control_code > 1
           AND l_ser_control_code <> 6 THEN
          IF (l_debug = 1) THEN
            mydebug('check_mmtt_mtl_status: Lot and serial controlled');
          END IF;

          OPEN ser_csr;

          LOOP
            FETCH ser_csr INTO l_serial_number;
            EXIT WHEN ser_csr%NOTFOUND;

            IF inv_material_status_grp.is_status_applicable(
                 p_wms_installed             => 'TRUE'
               , p_trx_status_enabled        => NULL
               , p_trx_type_id               => l_txn_type_id
               , p_lot_status_enabled        => NULL
               , p_serial_status_enabled     => NULL
               , p_organization_id           => l_org_id
               , p_inventory_item_id         => l_item_id
               , p_sub_code                  => NULL
               , p_locator_id                => NULL
               , p_lot_number                => l_lot_number
               , p_serial_number             => l_serial_number
               , p_object_type               => 'A'
               ) = 'N' THEN
              IF (l_debug = 1) THEN
                mydebug('check_mmtt_mtl_status: After 0');
              END IF;

              x_mtl_status := 1;
              RETURN;
            END IF;
          END LOOP;

          CLOSE ser_csr;
        ELSE
          IF inv_material_status_grp.is_status_applicable(
               p_wms_installed             => 'TRUE'
             , p_trx_status_enabled        => NULL
             , p_trx_type_id               => l_txn_type_id
             , p_lot_status_enabled        => NULL
             , p_serial_status_enabled     => NULL
             , p_organization_id           => l_org_id
             , p_inventory_item_id         => l_item_id
             , p_sub_code                  => NULL
             , p_locator_id                => NULL
             , p_lot_number                => l_lot_number
             , p_serial_number             => NULL
             , p_object_type               => 'O'
             ) = 'N' THEN
            IF (l_debug = 1) THEN
              mydebug('check_mmtt_mtl_status: After 1');
            END IF;

            x_mtl_status := 1;
            RETURN;
          END IF;
        END IF;
      END LOOP;

      CLOSE lot_csr;
    ELSIF l_ser_control_code > 1
          AND l_ser_control_code <> 6 THEN
      IF (l_debug = 1) THEN
        mydebug('check_mmtt_mtl_status: Serial controlled only');
      END IF;

      l_serial_temp_id := l_temp_id;
      -- serial controlled - CHECK serial status
      OPEN ser_csr;

      LOOP
        FETCH ser_csr INTO l_serial_number;
        EXIT WHEN ser_csr%NOTFOUND;

        IF inv_material_status_grp.is_status_applicable(
             p_wms_installed             => 'TRUE'
           , p_trx_status_enabled        => NULL
           , p_trx_type_id               => l_txn_type_id
           , p_lot_status_enabled        => NULL
           , p_serial_status_enabled     => NULL
           , p_organization_id           => l_org_id
           , p_inventory_item_id         => l_item_id
           , p_sub_code                  => NULL
           , p_locator_id                => NULL
           , p_lot_number                => NULL
           , p_serial_number             => l_serial_number
           , p_object_type               => 'S'
           ) = 'N' THEN
          IF (l_debug = 1) THEN
            mydebug('check_mmtt_mtl_status: After 6');
          END IF;

          x_mtl_status := 1;
          RETURN;
        END IF;
      END LOOP;

      CLOSE ser_csr;
    ELSE
      IF (l_debug = 1) THEN
        mydebug('check_mmtt_mtl_status: No controls');
      END IF;

      IF inv_material_status_grp.is_status_applicable(
           p_wms_installed             => 'TRUE'
         , p_trx_status_enabled        => NULL
         , p_trx_type_id               => l_txn_type_id
         , p_lot_status_enabled        => NULL
         , p_serial_status_enabled     => NULL
         , p_organization_id           => l_org_id
         , p_inventory_item_id         => l_item_id
         , p_sub_code                  => l_sub
         , p_locator_id                => l_loc
         , p_lot_number                => l_lot_number
         , p_serial_number             => NULL
         , p_object_type               => 'A'
         ) = 'N' THEN
        IF (l_debug = 1) THEN
          mydebug('check_mmtt_mtl_status: After Check');
        END IF;

        x_mtl_status := 1;
        RETURN;
      END IF;

      IF (l_debug = 1) THEN
        mydebug('check_mmtt_mtl_status: After Check');
      END IF;

      x_mtl_status := 0;
      RETURN;
    END IF;

    x_mtl_status := 0;
  END check_mmtt_mtl_status;

  -- added for bug 2271470

  PROCEDURE cleanup_partial_putaway_lpn(
    x_return_status  OUT NOCOPY     VARCHAR2
  , x_msg_count      OUT NOCOPY     NUMBER
  , x_msg_data       OUT NOCOPY     VARCHAR2
  , p_lpn_id         IN             NUMBER
  ) IS
    l_lpn_context NUMBER;
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

    -- Following variables added in ATF_J3

    -- End variables added in ATF_J3

    -- Bug# 3281512 - Performance Fixes
    -- Cursor added to retrieve valid MO header IDs so we can avoid
    -- the hash join problem.
    CURSOR c_header_id IS
       SELECT   moh.header_id
	 FROM   mtl_txn_request_headers moh, mtl_txn_request_lines mol
	 WHERE  moh.move_order_type = inv_globals.g_move_order_put_away
	 AND    moh.header_id = mol.header_id
	 AND    mol.lpn_id = p_lpn_id;
    l_header_id  NUMBER;

  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;

     -- ATF_J3
     -- Skip cleanup_partial_putaway_lpn logic
     -- if current release is J or above.
     -- We take care of cleaning up MMTT in suggestions_PUB

     IF (l_debug = 1) THEN
	mydebug('cleanup_partial_putaway_LPN: Current release is above J, return without doing anything.  p_lpn_id : ' || p_lpn_id);
     END IF;

     RETURN;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF (l_debug = 1) THEN
        mydebug('cleanup_partial_putaway_LPN  upexpected error: ' || SQLCODE);
      END IF;
  END cleanup_partial_putaway_lpn;

  /**
    * Inbound  -  Nested LPN changes
    * Creates Move order line by exploding the given lpn
    */


  PROCEDURE create_mo_lpn(
    p_lpn_id         IN NUMBER
  , p_org_id         IN NUMBER
  , x_return_status  OUT NOCOPY  VARCHAR2
  , x_msg_count      OUT NOCOPY  NUMBER
  , x_msg_data       OUT NOCOPY  VARCHAR2
  ) IS
    l_lpn_id                       NUMBER;
    l_m_item                       NUMBER;
    l_m_qty                        NUMBER;
    l_m_uom                        VARCHAR2(3);
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_m_lot                        VARCHAR2(80);
    l_m_rev                        VARCHAR2(3);
    l_m_hdr                        NUMBER;
    l_m_line                       NUMBER;
    l_m_sub                        VARCHAR2(10);
    l_m_loc                        NUMBER;
    l_return_status                VARCHAR2(1);
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);
    l_lpn_cg_id                    NUMBER;
    l_debug                        NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_project_id                   NUMBER;
    l_task_id                      NUMBER;

    l_m_sec_qty                    NUMBER;      --BUG12796808
    l_m_sec_uom                    VARCHAR2(3); --BUG12796808
    -- Bug# 3434940 - Performance Fixes
    -- Create a cursor to loop through all the nested LPNs within
    -- the given outer LPN, p_lpn_id.
    CURSOR lpn_csr IS
       SELECT lpn_id
	 FROM wms_license_plate_numbers
	 START WITH lpn_id = p_lpn_id
	 CONNECT BY PRIOR lpn_id = parent_lpn_id;
    l_current_lpn_id     NUMBER;

    -- Bug# 3434940 - Performance Fixes
    -- Rename this cursor to lpn_contents_csr.  Do not loop through the
    -- nested LPNs here.  We will open a seperate outer cursor called
    -- lpn_csr to do that.
    CURSOR lpn_contents_csr IS
       SELECT inventory_item_id
            , quantity
            , uom_code
            , lot_number
            , revision
            , cost_group_id
            , parent_lpn_id
			, secondary_quantity --BUG12796808
			, secondary_uom_code --BUG12796808
	 FROM   wms_lpn_contents
	 WHERE  parent_lpn_id = l_current_lpn_id;
  BEGIN
    -- Intialize out variables
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN lpn_csr;
    IF (l_debug = 1) THEN
       mydebug('create_mo_lpn: Opened lpn_csr');
    END IF;
    LOOP
       FETCH lpn_csr INTO l_current_lpn_id;
       EXIT WHEN lpn_csr%NOTFOUND;

       IF (l_debug = 1) THEN
	  mydebug('create_mo_lpn: Current LPN ID is - ' || l_current_lpn_id);
       END IF;
       OPEN lpn_contents_csr;
       IF (l_debug = 1) THEN
	  mydebug('create_mo_lpn: Opened lpn_contents_csr');
       END IF;

       LOOP
	  FETCH lpn_contents_csr INTO
	    l_m_item,
	    l_m_qty,
	    l_m_uom,
	    l_m_lot,
	    l_m_rev,
	    l_lpn_cg_id,
	    l_lpn_id,
		l_m_sec_qty, --BUG12796808
		l_m_sec_uom; --BUG12796808

	  EXIT WHEN lpn_contents_csr%NOTFOUND;

	  -- Close existing move orders detailed.
	  UPDATE mtl_txn_request_lines mol
	    SET mol.line_status = inv_globals.g_to_status_closed
	    WHERE mol.lpn_id = l_lpn_id
	    AND mol.organization_id   = p_org_id
	    AND mol.quantity_detailed > 0
	    AND EXISTS
            (SELECT 1
             FROM
             mtl_txn_request_headers moh,
             wms_license_plate_numbers wlc
             WHERE mol.header_id     = moh.header_id
             AND moh.move_order_type = inv_globals.g_move_order_put_away
             AND wlc.lpn_id          = mol.lpn_id
             AND wlc.lpn_context     = 1);

	  IF (l_debug = 1) THEN
	     mydebug('create_mo_lpn: lpn loop');
	     mydebug('create_mo_lpn: lot' || l_m_lot);
	     mydebug('item              ' || l_m_item);
	     mydebug('uom               ' || l_m_uom);
	     mydebug('rev               ' || l_m_rev);
	     mydebug('cost group id     ' || l_lpn_cg_id);
	     mydebug('lpn_id            ' || l_lpn_id);
 	     mydebug('l_m_sec_qty       ' || l_m_sec_qty);
 	     mydebug('l_m_sec_uom       ' || l_m_sec_uom);
	  END IF;

	  SELECT subinventory_code
               , locator_id
	    INTO    l_m_sub
                  , l_m_loc
	    FROM   wms_license_plate_numbers
	    WHERE  lpn_id = l_lpn_id;

	  SELECT mil.project_id
	       , mil.task_id
	    INTO   l_project_id
	         , l_task_id
	    FROM   mtl_item_locations mil
	    WHERE  mil.inventory_location_id = l_m_loc
	    AND    mil.organization_id = p_org_id
	    AND    mil.subinventory_code = l_m_sub;

	  -- Call create_mo
	  IF (l_debug = 1) THEN
	     mydebug('create_mo_lpn: Calling create_mo');
	  END IF;

	  wms_task_dispatch_put_away.create_mo
	    (p_org_id                         => p_org_id,
	     p_inventory_item_id              => l_m_item,
	     p_qty                            => l_m_qty,
	     p_uom                            => l_m_uom,
	     p_lpn                            => l_lpn_id,
	     p_project_id                     => l_project_id,
	     p_task_id                        => l_task_id,
	     p_lot_number                     => l_m_lot,
	     p_revision                       => l_m_rev,
	     p_header_id                      => l_m_hdr,
	     p_sub                            => l_m_sub,
	     p_loc                            => l_m_loc,
	     x_line_id                        => l_m_line,
	     p_inspection_status              => NULL,
	     p_transaction_type_id            => 64,
	     p_transaction_source_type_id     => 4,
	     p_wms_process_flag               => NULL,
	     x_return_status                  => l_return_status,
	     x_msg_count                      => l_msg_count,
	     x_msg_data                       => l_msg_data,
	     p_from_cost_group_id             => l_lpn_cg_id,
		 p_sec_qty                        => l_m_sec_qty,  --BUG12796808
         p_sec_uom                        => l_m_sec_uom   --BUG12796808
	    );

	  l_m_hdr := NULL;
	  fnd_msg_pub.count_and_get(p_count => l_msg_count, p_data => l_msg_data);

	  IF (l_msg_count = 0) THEN
	     IF (l_debug = 1) THEN
		mydebug('create_mo_lpn: Successful');
	     END IF;
	   ELSIF(l_msg_count = 1) THEN
	     IF (l_debug = 1) THEN
		mydebug('create_mo_lpn: Not Successful');
		mydebug('create_mo_lpn: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
	     END IF;
	   ELSE
	     IF (l_debug = 1) THEN
		mydebug('create_mo_lpn: Not Successful2');
	     END IF;

	     FOR i IN 1 .. l_msg_count LOOP
		l_msg_data := fnd_msg_pub.get(i, 'F');

		IF (l_debug = 1) THEN
		   mydebug('create_mo_lpn: ' || REPLACE(l_msg_data, fnd_global.local_chr(0), ' '));
		END IF;
	     END LOOP;
	  END IF;

	  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
	     fnd_message.set_name('WMS', 'WMS_TD_CMO_ERROR');
	     fnd_msg_pub.ADD;
	     RAISE fnd_api.g_exc_error;
	   ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
	     fnd_message.set_name('WMS', 'WMS_TD_CMO_ERROR');
	     fnd_msg_pub.ADD;
	     RAISE fnd_api.g_exc_error;
	  END IF;

	  IF (l_debug = 1) THEN
	     mydebug('create_mo: Line ID created');
	     mydebug('create_mo: ' || l_m_line);
	  END IF;

       END LOOP;
       CLOSE lpn_contents_csr;

    END LOOP;
    CLOSE lpn_csr;

  EXCEPTION
     WHEN fnd_api.g_exc_error THEN
	x_return_status := fnd_api.g_ret_sts_error;
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_mo_lpn;


  PROCEDURE validate_against_rules(
    p_organization_id    IN             NUMBER
  , p_lpn_id             IN             NUMBER
  , p_subinventory       IN             VARCHAR2
  , p_locator_id         IN             NUMBER
  , p_user_id            IN             NUMBER
  , p_eqp_ins            IN             VARCHAR2
  , p_project_id         IN             NUMBER
  , p_task_id            IN             NUMBER
  , x_return_status      OUT NOCOPY     VARCHAR2
  , x_msg_count          OUT NOCOPY     NUMBER
  , x_msg_data           OUT NOCOPY     VARCHAR2
  , x_validation_passed  OUT NOCOPY     VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'validate_against_rules';
    l_progress          VARCHAR2(10);
    l_mo_lines_count    NUMBER;
    l_mmtt_lines_count  NUMBER;
    l_number_of_rows    NUMBER;
    l_return_status     VARCHAR2(1);
    l_crossdock         VARCHAR2(3);
    l_fully_allocated   BOOLEAN      := TRUE;
    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_is_content_lpn    VARCHAR2(1)  := 'N';
    l_is_mo_there       VARCHAR2(1)  := 'N';
    l_lpn_context       NUMBER;
    l_lpn_id            NUMBER;
    l_is_mo_created     VARCHAR2(1)  := 'N';
    l_emp_id            NUMBER;

    CURSOR qty_check_cursor IS
      SELECT mtrl.primary_quantity
           , mmtt.primary_quantity
      FROM   mtl_txn_request_lines mtrl, mtl_material_transactions_temp mmtt
      WHERE  mtrl.organization_id = p_organization_id
      AND    mtrl.lpn_id = l_lpn_id
      AND    mmtt.move_order_line_id = mtrl.line_id;

    l_mo_primary_qty    NUMBER;
    l_mmtt_primary_qty  NUMBER;

    CURSOR lpn_cur IS
      SELECT lpn_id
	FROM wms_license_plate_numbers
	START WITH lpn_id = p_lpn_id
	CONNECT BY parent_lpn_id = PRIOR lpn_id;

  BEGIN
    IF (l_debug = 1) THEN
      mydebug('***Calling validate_against_rules***');
    END IF;

    -- Set the savepoint
    SAVEPOINT validate_rules_sp;
    x_return_status := fnd_api.g_ret_sts_success;
    l_progress := '10';

    -- Call the ATF API to abort the plan before deleting the MMTTs

    -- Patchset level check
    mydebug('validate_against_rules: Current release is above J.');

    BEGIN -- Abort op plan call

       mydebug('validate_against_rules: Calling ATF_For_Manual_Drop to abort the plan, if any');

       l_progress := '12';
       WMS_PUTAWAY_UTILS.ATF_For_Manual_Drop(
					     x_return_status => x_return_status
					     ,x_msg_count     => x_msg_count
					     ,x_msg_data      => x_msg_data
					     ,p_call_type     => G_ATF_ABORT_PLAN
					     ,p_org_id        => p_organization_id
					     ,p_lpn_id        => p_lpn_id
					     ,p_emp_id        => NULL
					     );
       l_progress := '13';

       IF x_return_status = fnd_api.g_ret_sts_success THEN
          -- Abort op plan completed successfully.
          NULL;

        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;

        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;

       END IF;
       l_progress := '18';

    EXCEPTION
       WHEN OTHERS THEN
          RAISE fnd_api.g_exc_unexpected_error;
    END; -- Abort op plan call


    OPEN lpn_cur;
    LOOP
      FETCH lpn_cur INTO l_lpn_id;

      l_is_content_lpn := 'N';
      IF lpn_cur%notfound THEN
	 EXIT;
      END IF;

      BEGIN
        SELECT 'Y' INTO l_is_content_lpn
        FROM wms_lpn_contents
        WHERE parent_lpn_id = l_lpn_id;
      EXCEPTION
        WHEN no_data_found THEN
          l_is_content_lpn := 'N';
        WHEN too_many_rows THEN
          l_is_content_lpn := 'Y';
      END;

      IF (l_is_content_lpn = 'Y') THEN

	 --BUG 3369873:  We no longer need to call revert_loc_suggested_capacity
	 --because it is done inside abort_operation_instance_already.

          -- Clean up any old existing MMTT, MTLT, and WDT records
          -- which might exist if on the user directed putaway mobile page,
          -- you are performing a user drop and you navigate back to the loc
          -- to enter a different one than before.
          IF (l_debug = 1) THEN
            mydebug('Clean up old WDT, MTLT, and MMTT records first');
          END IF;

          -- Before clean up call abort operations plan

          -- After Abort Operation plan do clean up.

          DELETE FROM wms_dispatched_tasks
          WHERE task_type = 2
          AND   transaction_temp_id IN
                (SELECT transaction_temp_id
                 FROM   mtl_material_transactions_temp
                 WHERE  move_order_line_id IN
                    (SELECT line_id
                     FROM   mtl_txn_request_lines
                     WHERE  organization_id = p_organization_id
                     AND    lpn_id = l_lpn_id)
                );

          DELETE FROM mtl_transaction_lots_temp
          WHERE transaction_temp_id IN
              (SELECT transaction_temp_id
               FROM   mtl_material_transactions_temp
               WHERE  move_order_line_id IN
                  (SELECT line_id
                   FROM   mtl_txn_request_lines
                   WHERE  organization_id = p_organization_id
                   AND    lpn_id = l_lpn_id));

          DELETE FROM mtl_material_transactions_temp
          WHERE move_order_line_id IN
              (SELECT line_id
               FROM   mtl_txn_request_lines
               WHERE  organization_id = p_organization_id
               AND    lpn_id = l_lpn_id);

          IF (l_debug = 1) THEN
            mydebug('Finished cleaning up old WDT, MTLT, and MMTT records');
          END IF;

          l_progress := '40';

          -- Update the move order lines with the user inputted sub/loc.
          -- Also null out the quantity detailed in case the user enters
          -- a loc, validates it against rules, but then goes back and changes
          -- the sub/loc before processing it.
          UPDATE mtl_txn_request_lines
	    SET to_subinventory_code = p_subinventory
            , to_locator_id = p_locator_id
            , quantity_detailed = NULL
	    WHERE  organization_id = p_organization_id
	    AND    lpn_id = l_lpn_id
	    AND    line_status = 7;

          l_progress := '50';

          -- Call the rules engine and see if MMTT suggestions are returned
          -- This allows for rules engine validation of the user inputted sub/loc
          -- Bug# 2752119
          -- Added an extra input parameter in API call so we will not check for
          -- crossdocking opportunities for rules validated express drops
          wms_task_dispatch_put_away.suggestions_pub(
            p_lpn_id                  => l_lpn_id
          , p_org_id                  => p_organization_id
          , p_user_id                 => p_user_id
          , p_eqp_ins                 => p_eqp_ins
          , x_number_of_rows          => l_number_of_rows
          , x_return_status           => l_return_status
          , x_msg_count               => x_msg_count
          , x_msg_data                => x_msg_data
          , x_crossdock               => l_crossdock
          , p_status                  => 4
          , p_check_for_crossdock     => 'N'
          , p_drop_type               => 'MD' -- Manual drop
          , p_subinventory            =>  p_subinventory
          , p_locator_id              =>  p_locator_id );

          IF (l_debug = 1) THEN
            mydebug('Finished calling the suggestions_pub API');
          END IF;

          l_progress := '60';

          -- Check to see if the suggestions_pub returned successfully
          IF (l_return_status = fnd_api.g_ret_sts_success) THEN
            IF (l_debug = 1) THEN
              mydebug('Success returned from suggestions_pub API');
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              mydebug('Failure returned from suggestions_pub API');
            END IF;

            RAISE fnd_api.g_exc_error;
          END IF;

	  -- Bug# 3352224
	  -- For Patchset J and above, we allow manual drops within
	  -- Inventory.	 Therefore the call to suggestions_pub would
	  -- create move order lines if none existed for inventory LPNs.
	  -- The query to see how many move order lines there are for the
	  -- LPN should be done after the call to suggestions_pub and not before.

          -- Get the number of move order lines for this given LPN
          SELECT COUNT(1)
	    INTO   l_mo_lines_count
	    FROM   mtl_txn_request_lines
	    WHERE  organization_id = p_organization_id
	    AND    lpn_id = l_lpn_id
	    AND    line_status = 7;

          IF (l_debug = 1) THEN
            mydebug('The number of move order lines is: ' || l_mo_lines_count);
          END IF;

          l_progress := '70';

          -- Check to see if MMTT allocations were created
          SELECT COUNT(mmtt.transaction_temp_id)
          INTO   l_mmtt_lines_count
          FROM   mtl_material_transactions_temp mmtt, mtl_txn_request_lines mtrl
          WHERE  mtrl.lpn_id = l_lpn_id
          AND    mtrl.organization_id = p_organization_id
          AND    NVL(mmtt.wms_task_type, 0) <> -1
          AND    mtrl.line_id = mmtt.move_order_line_id
          AND    NVL(mtrl.project_id, -1) = DECODE(mtrl.project_id, NULL, -1, NVL(p_project_id, NVL(mtrl.project_id, -1)))
          AND    NVL(mtrl.task_id, -1) = DECODE(mtrl.task_id, NULL, -1, NVL(p_task_id, NVL(mtrl.task_id, -1)));

          IF (l_debug = 1) THEN
            mydebug('Checked to see how many MMTT lines were created: ' || l_mmtt_lines_count);
          END IF;

          l_progress := '80';

          -- Check that for every move order line, exactly one MMTT suggestion is created
          IF (l_mmtt_lines_count = 0
              OR l_mmtt_lines_count <> l_mo_lines_count) THEN
            IF (l_debug = 1) THEN
              mydebug('Rules engine validation failed!');
            END IF;

            x_validation_passed := 'N';

            -- Bug #2745971
            -- We need to explicitly revert the locator capacities since this is
            -- done autonomously by the rules engine.  Performing a rollback
            -- will not revert the locator capacities.
            IF (l_debug = 1) THEN
              mydebug('Call revert_loc_suggested_capacity to clean up capacities');
            END IF;

            wms_task_dispatch_put_away.revert_loc_suggested_capacity(
              x_return_status       => l_return_status
            , x_msg_count           => x_msg_count
            , x_msg_data            => x_msg_data
            , p_organization_id     => p_organization_id
            , p_lpn_id              => p_lpn_id
            );
            l_progress := '90';

            -- Check to see if the call to revert_loc_suggested_capacity returned successfully
            IF (l_return_status = fnd_api.g_ret_sts_success) THEN
              IF (l_debug = 1) THEN
                mydebug('Success returned from revert_loc_suggested_capacity API');
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                mydebug('Failure returned from revert_loc_suggested_capacity API');
              END IF;
              -- Bug 5393727: do not raise an exception if revert API returns an error
              -- RAISE fnd_api.g_exc_error;
            END IF;

            -- Perform a rollback to clean up the rest of the data
            BEGIN
              ROLLBACK TO validate_rules_sp;
            EXCEPTION WHEN OTHERS THEN
              NULL;
            END;
            EXIT;
          ELSE
            -- Bug #2745971
            -- Check to see if the MMTT allocations are all full allocations,
            -- i.e. not partially allocated suggestions
            IF (l_debug = 1) THEN
              mydebug('Check if suggestions are fully allocated');
            END IF;

            OPEN qty_check_cursor;

            LOOP
              FETCH qty_check_cursor INTO l_mo_primary_qty, l_mmtt_primary_qty;
              EXIT WHEN qty_check_cursor%NOTFOUND;

              --IF (l_mo_primary_qty <> l_mmtt_primary_qty) THEN
              IF (Abs(l_mo_primary_qty - l_mmtt_primary_qty)>0.00005) THEN   -- made when testing 13591755
                -- If any of the MOL and corresponding MMTT lines have
                -- different primary quantities, the line was only partially allocated
                l_fully_allocated := FALSE;
                EXIT;
              END IF;
            END LOOP;

            CLOSE qty_check_cursor;

            IF (l_debug = 1) THEN
              mydebug('Finished checking for full allocations');
            END IF;

            l_progress := '100';

            -- Rules engine validation should fail if the lines are not fully allocated
            IF (l_fully_allocated) THEN
              IF (l_debug = 1) THEN
                mydebug('Rules engine validation passed!');
              END IF;

              x_validation_passed := 'Y';
            ELSE
              IF (l_debug = 1) THEN
                mydebug('Rules engine validation failed!');
              END IF;

              x_validation_passed := 'N';

              -- Bug #2745971
              -- We need to explicitly revert the locator capacities since this is
              -- done autonomously by the rules engine.  Performing a rollback
              -- will not revert the locator capacities.
              IF (l_debug = 1) THEN
                mydebug('Call revert_loc_suggested_capacity to clean up capacities');
              END IF;

              wms_task_dispatch_put_away.revert_loc_suggested_capacity(
                x_return_status       => l_return_status
              , x_msg_count           => x_msg_count
              , x_msg_data            => x_msg_data
              , p_organization_id     => p_organization_id
              , p_lpn_id              => p_lpn_id
              );
              l_progress := '110';

              -- Check to see if the call to revert_loc_suggested_capacity returned successfully
              IF (l_return_status = fnd_api.g_ret_sts_success) THEN
                IF (l_debug = 1) THEN
                  mydebug('Success returned from revert_loc_suggested_capacity API');
                END IF;
              ELSE
                IF (l_debug = 1) THEN
                  mydebug('Failure returned from revert_loc_suggested_capacity API');
                END IF;
                -- Bug 5393727: do not raise an exception if revert API returns an error
                -- RAISE fnd_api.g_exc_error;
              END IF;

              -- Perform a rollback to clean up the rest of the data
              BEGIN
                ROLLBACK TO validate_rules_sp;
              EXCEPTION WHEN OTHERS THEN
                 NULL;
              END;
              EXIT;
            END IF;
          END IF;

          l_progress := '120';
          x_return_status := fnd_api.g_ret_sts_success;

      END IF;
  END LOOP;

  -- Call the ATF API to insert WDTs.
  -- Moved the ATF API calls to the complete_putaway_wrapper API instead.  -etam

  IF (l_debug = 1) THEN
     mydebug('***End of validate_against_rules***');
  END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO validate_rules_sp;
      x_validation_passed := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting validate_against_rules - Execution error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO validate_rules_sp;
      x_validation_passed := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting validate_against_rules - Unexpected error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO validate_rules_sp;
      x_validation_passed := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting validate_against_rules - Others exception: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
  END validate_against_rules;


  PROCEDURE create_user_suggestions(
    p_organization_id  IN             NUMBER
  , p_lpn_id           IN             NUMBER
  , p_subinventory     IN             VARCHAR2
  , p_locator_id       IN             NUMBER
  , p_user_id          IN             NUMBER
  , p_eqp_ins          IN             VARCHAR2
  , x_return_status    OUT NOCOPY     VARCHAR2
  , x_msg_count        OUT NOCOPY     NUMBER
  , x_msg_data         OUT NOCOPY     VARCHAR2
  , x_number_of_rows   OUT NOCOPY     NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'create_user_suggestions';
    l_progress          VARCHAR2(10);
    l_txn_header_id     NUMBER;
    l_txn_temp_id       NUMBER;
    l_ser_trx_id        NUMBER;
    l_trx_action_id     NUMBER;
    l_completion_txn_id NUMBER;
    l_primary_uom_code  VARCHAR2(3);
    l_task_id           NUMBER;
    l_return            NUMBER;
    l_number_of_rows    NUMBER       := 0;
    l_mo_exists         VARCHAR2(1)  := 'N';
    l_lpn_context       NUMBER;
    l_is_mo_created     VARCHAR2(1)  := 'N';
    l_subinventory      mtl_secondary_inventories.secondary_inventory_name%TYPE;
    l_locator_id        NUMBER;
    l_operation_seq_num  NUMBER := NULL;
    l_repetitive_line_id NUMBER := NULL;

    TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE var3_tab IS TABLE OF VARCHAR(3) INDEX BY BINARY_INTEGER;
    l_mmtt_id_tab num_tab;
    l_mmtt_qty_tab num_tab;
    l_mmtt_mol_id_tab num_tab;
    l_mmtt_uom_tab var3_tab;
    l_mmtt_sec_qty_tab num_tab; --OPM Convergence
    l_mmtt_sec_uom_tab var3_tab; --OPM Convergence

    -- Bug# 3281512 - Performance Fixes
    -- Cursor to retrieve the nested LPNs within a given outer LPN
    CURSOR nested_lpn_cursor IS
       SELECT lpn_id
	 FROM wms_license_plate_numbers
	 START WITH lpn_id = p_lpn_id
	 CONNECT BY PRIOR lpn_id = parent_lpn_id;
    l_current_lpn_id    NUMBER;

    -- Nested LPN changes.
    -- Changed MO Lines cursor to not consider closed move orders
    -- Bug# 3281512 - Performance Fixes
    --
    CURSOR mo_lines_cursor IS
       SELECT mol.lpn_id
            , mol.line_id
            , mol.inventory_item_id
            , mol.revision
            , mol.lot_number
            , mol.uom_code
            , mol.quantity
            , mol.primary_quantity
            , mol.reference_id
            , mol.project_id
            , mol.task_id
            , mol.txn_source_id
            , mol.transaction_type_id
            , mol.transaction_source_type_id
            , mol.to_cost_group_id
			, mol.SECONDARY_QUANTITY --BUG12796808
			, mol.SECONDARY_UOM_CODE --BUG12796808
	 FROM   mtl_txn_request_lines mol
	 WHERE  mol.organization_id   = p_organization_id
	 AND    mol.header_id IN (SELECT moh.header_id
				  FROM mtl_txn_request_headers moh
				  WHERE moh.move_order_type = inv_globals.g_move_order_put_away
				  )
	 AND    mol.line_status = 7
	 AND    mol.lpn_id = l_current_lpn_id;

    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_emp_id            NUMBER;



  BEGIN
    IF (l_debug = 1) THEN
      mydebug('***Calling create_user_suggestions***');
    END IF;

    -- Set the savepoint
    SAVEPOINT create_suggestions_sp;
    l_progress := '10';

    -- Bug# 2750060
    -- Get the employee ID so we can populate
    -- the person_id column in WDT properly.
    IF (l_debug = 1) THEN
      mydebug('Get the employee ID tied to the user');
    END IF;

    BEGIN
      SELECT employee_id
      INTO   l_emp_id
      FROM   fnd_user
      WHERE  user_id = p_user_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (l_debug = 1) THEN
          mydebug('There is no employee tied to the user');
        END IF;

        l_emp_id := NULL;
    END;

    IF (l_debug = 1) THEN
      mydebug('Employee ID: ' || l_emp_id);
    END IF;

    l_progress := '20';

    -- Call the ATF API to abort the plan before deleting the MMTTs

    -- Patchset level check
    mydebug('create_user_suggestions: Current release is above J.');

    BEGIN -- Abort op plan call

       mydebug('create_user_suggestions: Calling WMS_PUTAWAY_UTILS.ATF_For_Manual_Drop to abort the plan, if any');

       l_progress := '22';
       WMS_PUTAWAY_UTILS.ATF_For_Manual_Drop(
					     x_return_status => x_return_status
					     ,x_msg_count     => x_msg_count
					     ,x_msg_data      => x_msg_data
					     ,p_call_type     => G_ATF_ABORT_PLAN
					     ,p_org_id        => p_organization_id
					     ,p_lpn_id        => p_lpn_id
					     ,p_emp_id        => l_emp_id
					     );
       l_progress := '23';

       IF x_return_status = fnd_api.g_ret_sts_success THEN
          -- Abort op plan completed successfully.
          NULL;

        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;

        ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;

       END IF;
       l_progress := '28';

    EXCEPTION
       WHEN OTHERS THEN
          RAISE fnd_api.g_exc_unexpected_error;
    END; -- Abort op plan call


    -- Clean up any old existing MMTT, MTLT, and WDT records
    -- which might exist if on the user directed putaway mobile page,
    -- you are performing a user drop and you navigate back to the loc
    -- to enter a different one than before.
    IF (l_debug = 1) THEN
      mydebug('Clean up old WDT, MTLT, and MMTT records');
    END IF;


    -- Nested LPN changes
    -- Select the old MMTTs.  Delete them at the end.
    -- Bug# 3434940 - Performance Fixes
    -- For now we will leave the hash join problem.  We're not able
    -- to use the outer nested_lpn_cursor because of the bulk collect.
    SELECT mmtt.transaction_temp_id,
      mmtt.transaction_quantity,
      mmtt.transaction_uom,
      mmtt.move_order_line_id,
      mmtt.secondary_transaction_quantity, --OPM Convergence
      mmtt.secondary_uom_code --OPM Convergence
      bulk collect
      INTO l_mmtt_id_tab,
      l_mmtt_qty_tab,
      l_mmtt_uom_tab,
      l_mmtt_mol_id_tab,
      l_mmtt_sec_qty_tab, --OPM Convergence
      l_mmtt_sec_uom_tab --OPM Convergence
      FROM mtl_material_transactions_temp mmtt,
      mtl_txn_request_lines mtrl
      WHERE mmtt.organization_id = p_organization_id
      AND mmtt.move_order_line_id = mtrl.line_id
      AND mtrl.lpn_id IN (SELECT lpn_id
			  FROM wms_license_plate_numbers
			  START WITH lpn_id = p_lpn_id
			  CONNECT BY parent_lpn_id = PRIOR lpn_id);



    SELECT lpn_context,subinventory_code,locator_id
      INTO l_lpn_context,l_subinventory,l_locator_id
      FROM wms_license_plate_numbers
      WHERE lpn_id = p_lpn_id;

    IF l_lpn_context = 1 THEN
       -- Inventory LPN so need to create MOLs first
       create_mo_lpn( p_lpn_id        => p_lpn_id
		      , p_org_id        => p_organization_id
		      , x_return_status => x_return_status
		      , x_msg_count     => x_msg_count
		      , x_msg_data      => x_msg_data );

       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       END IF;
    END IF; -- End for is Inventory lpn

    l_progress := '30';

    -- Loop through the move order lines cursor
    -- Bug# 3281512 - Performance Fixes
    -- Open up the nested LPN cursor first and for each LPN,
    -- loop through the move order lines cursor.
    OPEN nested_lpn_cursor;
    LOOP
       FETCH nested_lpn_cursor INTO l_current_lpn_id;
       EXIT WHEN nested_lpn_cursor%NOTFOUND;
       IF (l_debug = 1) THEN
	  mydebug('Current LPN ID: ' || l_current_lpn_id);
       END IF;

       FOR v_mo_line IN mo_lines_cursor LOOP
	  l_number_of_rows := l_number_of_rows + 1;

	  IF (l_debug = 1) THEN
	     mydebug('Current move order line values:');
	     mydebug('LPN ID:==============> ' || v_mo_line.lpn_id);
	     mydebug('Line ID: ============> ' || v_mo_line.line_id);
	     mydebug('Inventory Item ID: ==> ' || v_mo_line.inventory_item_id);
	     mydebug('Revision: ===========> ' || v_mo_line.revision);
	     mydebug('Lot Number: =========> ' || v_mo_line.lot_number);
	     mydebug('UOM Code: ===========> ' || v_mo_line.uom_code);
	     mydebug('Qty: ================> ' || v_mo_line.quantity);
	     mydebug('Primary Qty: ========> ' || v_mo_line.primary_quantity);
	     mydebug('Project ID: =========> ' || v_mo_line.project_id);
	     mydebug('Task ID: ============> ' || v_mo_line.task_id);
	     mydebug('Txn Source ID: ======> ' || v_mo_line.txn_source_id);
	     mydebug('Txn Type ID: ========> ' || v_mo_line.transaction_type_id);
	     mydebug('Txn Source Type ID: => ' || v_mo_line.transaction_source_type_id);
	     mydebug('Cost Group ID: ======> ' || v_mo_line.to_cost_group_id);
	     mydebug('SECONDARY_QUANTITY: => ' || v_mo_line.SECONDARY_QUANTITY);
	     mydebug('SECONDARY_UOM_CODE: => ' || v_mo_line.SECONDARY_UOM_CODE);
	  END IF;

	  -- Get a new transaction header id from the sequence
	  SELECT mtl_material_transactions_s.NEXTVAL
	    INTO   l_txn_header_id
	    FROM   DUAL;

	  IF (l_debug = 1) THEN
	     mydebug('Transaction header ID: ' || l_txn_header_id);
	  END IF;

	  l_progress := '40';

	  -- Get the value for the transaction action ID
	  IF (v_mo_line.transaction_source_type_id = 5
	      AND v_mo_line.transaction_type_id = 44) THEN
	     -- WIP assembly completion
	     l_trx_action_id := 31;
	   ELSIF(v_mo_line.transaction_source_type_id = 1
		 AND v_mo_line.transaction_type_id = 18) THEN
	     -- Purchase order receipt
	     l_trx_action_id := 27;
	   ELSIF(v_mo_line.transaction_source_type_id = 7
		 AND v_mo_line.transaction_type_id = 61) THEN
	     --Internal Req/Intransit Shipment Receipt
	     l_trx_action_id := 12;
	   ELSIF(v_mo_line.transaction_source_type_id = 8
		 AND v_mo_line.transaction_type_id = 62) THEN
	     -- Internal order intransit shipment
	     l_trx_action_id := 21;
	   ELSIF(v_mo_line.transaction_source_type_id = 12
		 AND v_mo_line.transaction_type_id = 15) THEN
	     -- RMA receipt of customer return
	     l_trx_action_id := 27;
	   ELSIF(v_mo_line.transaction_source_type_id = 4) THEN
	     -- Inventory lpn
	     l_trx_action_id := 2;
	   ELSIF(v_mo_line.transaction_source_type_id = 13
         AND v_mo_line.transaction_type_id = 12) THEN --bug9911977
         --Intransit Shipment Receipt
         l_trx_action_id :=12;
	   ELSE
	     -- This case should never come about
	     l_trx_action_id := -999;
	  END IF;

	  IF (l_debug = 1) THEN
	     mydebug('Transaction action ID is: ' || l_trx_action_id);
	  END IF;

	  l_progress := '50';

	  IF (l_debug = 1) THEN
	     mydebug('Getting operation_seq_num and repetive_line_id for mol: ' || v_mo_line.line_id);
	  END IF;
	  l_progress := '52';
	  BEGIN
	     SELECT DISTINCT operation_seq_num, repetitive_line_id
	       INTO l_operation_seq_num,l_repetitive_line_id
	       FROM mtl_material_transactions_temp
	       WHERE move_order_line_id = v_mo_line.line_id;
	     IF (l_debug = 1) THEN
		mydebug(' operation_seq_num ===> '|| l_operation_seq_num);
		mydebug(' repetive_line_id ====> '|| l_repetitive_line_id);
	     END IF;
	     l_progress := '53';
	  EXCEPTION
	     WHEN no_data_found THEN
		l_operation_seq_num := NULL;
		l_repetitive_line_id := NULL;
	     WHEN OTHERS THEN
		IF (l_debug = 1) THEN
		      mydebug('These values are not distinct!!');
		END IF;
		RAISE fnd_api.g_exc_error;
	  END;

	  -- Insert a record into MMTT
	  -- Nested LPN changes,
	  -- For Resides in Receiving LPNs insert destination sub destint loc as sub and loc
	  -- For Resides in Inventory LPNs insert destination sub and loc as to_sub and to_loc.


          mydebug('lpn context =====>' || l_lpn_context );
          mydebug('l_subinventory  =====>' || l_subinventory );
          mydebug('p_subinventory  =====>' || p_subinventory );
          mydebug('l_locator_id  =====>' || l_locator_id );
          mydebug('p_locator_id  =====>' || p_locator_id );

	  IF l_lpn_context = 3  OR l_lpn_context = 2 THEN --added context =2 bug 4189437

	     l_return :=
	       inv_trx_util_pub.insert_line_trx
	       (p_trx_hdr_id          => l_txn_header_id,
		p_item_id             => v_mo_line.inventory_item_id,
		p_revision            => v_mo_line.revision,
		p_org_id              => p_organization_id,
		p_trx_action_id       => l_trx_action_id,
		p_subinv_code         => p_subinventory,
		p_locator_id          => p_locator_id,
		p_trx_type_id         => v_mo_line.transaction_type_id,
		p_trx_src_type_id     => v_mo_line.transaction_source_type_id,
		p_trx_qty             => v_mo_line.quantity,
		p_pri_qty             => v_mo_line.primary_quantity,
		p_uom                 => v_mo_line.uom_code,
		p_user_id             => p_user_id,
		p_cost_group          => v_mo_line.to_cost_group_id,
		p_from_lpn_id         => v_mo_line.lpn_id,
		p_trx_src_id          => v_mo_line.txn_source_id,
		x_trx_tmp_id          => l_txn_temp_id,
		x_proc_msg            => x_msg_data,
		p_project_id          => v_mo_line.project_id,
		p_task_id             => v_mo_line.task_id,
		p_transaction_status  => 2,
		p_secondary_trx_qty   => v_mo_line.SECONDARY_QUANTITY,
		p_secondary_uom       => v_mo_line.SECONDARY_UOM_CODE
		);
	     --BUG 3356366: Insert MMTT with txn_status 2 so that it won't
	     --invoke the DB trigger that calls update_loc_suggested_capacity
	   ELSE
	     l_return :=
	       inv_trx_util_pub.insert_line_trx
	       (p_trx_hdr_id          => l_txn_header_id,
		p_item_id             => v_mo_line.inventory_item_id,
		p_revision            => v_mo_line.revision,
		p_org_id              => p_organization_id,
		p_trx_action_id       => l_trx_action_id,
		p_subinv_code         => nvl(l_subinventory,p_subinventory), -- 4156992
		p_locator_id          => nvl(l_locator_id,p_locator_id) , -- 4156992
		p_trx_type_id         => v_mo_line.transaction_type_id,
		p_trx_src_type_id     => v_mo_line.transaction_source_type_id,
		p_trx_qty             => v_mo_line.quantity,
		p_pri_qty             => v_mo_line.primary_quantity,
		p_uom                 => v_mo_line.uom_code,
		p_user_id             => p_user_id,
		p_cost_group          => v_mo_line.to_cost_group_id,
		p_from_lpn_id         => v_mo_line.lpn_id,
		p_trx_src_id          => v_mo_line.txn_source_id,
		x_trx_tmp_id          => l_txn_temp_id,
		x_proc_msg            => x_msg_data,
		p_project_id          => v_mo_line.project_id,
		p_task_id             => v_mo_line.task_id,
		p_tosubinv_code       => p_subinventory,
	        p_tolocator_id        => p_locator_id,
	        p_transaction_status => 2,
		p_secondary_trx_qty   => v_mo_line.SECONDARY_QUANTITY,
		p_secondary_uom       => v_mo_line.SECONDARY_UOM_CODE
		);

	     --BUG 3356366: Insert MMTT with txn_status 2 so that it won't
	     --invoke the DB trigger that calls update_loc_suggested_capacity
	  END IF;

	  IF (l_debug = 1) THEN
	     mydebug('Successfully inserted MMTT record: ' || l_txn_temp_id);
	  END IF;

	  l_progress := '60';

	  IF (l_return <> 0) THEN
	     ROLLBACK TO create_suggestions_sp;

	     IF (l_debug = 1) THEN
		mydebug('Error occurred while calling inv_trx_util_pub.insert_line_trx');
	     END IF;

	     RAISE fnd_api.g_exc_unexpected_error;
	  END IF;

	  -- Get the value for the completion_transaction_id
	  -- in the case of WIP completions
	  IF (v_mo_line.transaction_source_type_id = 5 AND
	      v_mo_line.transaction_type_id = 44) THEN
	     SELECT NVL(completion_transaction_id, -999)
	       INTO   l_completion_txn_id
	       FROM   wip_lpn_completions
	       WHERE  header_id = v_mo_line.reference_id
	       AND    lpn_id = p_lpn_id;
	   ELSE
	     l_completion_txn_id := NULL;
	  END IF;

	  IF (l_debug = 1) THEN
	     mydebug('Completion transaction ID: ' || l_completion_txn_id);
	  END IF;

	  l_progress := '70';

	  -- Get the item's primary uom code
	  SELECT primary_uom_code
	    INTO   l_primary_uom_code
	    FROM   mtl_system_items
	    WHERE  inventory_item_id = v_mo_line.inventory_item_id
	    AND    organization_id = p_organization_id;

	  IF (l_debug = 1) THEN
	     mydebug('Item primary UOM code: ' || l_primary_uom_code);
	  END IF;

	  l_progress := '80';

	  --Need to update MOL.quantity_detailed
	  --Because in WMSOPIBB.COMPLETE, it will deduct
	  --MMTT.TRANSACTION_QUANTITY from MOL.QUANITY_DETIALED
	  UPDATE mtl_txn_request_lines
	    SET  quantity_detailed = Nvl(quantity_detailed,0)+quantity
	    WHERE line_id = v_mo_line.line_id;

	  -- Update the MMTT record with the move order line,
	  -- completion transaction ID in the case of WIP completion,
	  -- item primary UOM code, transaction status (2 for suggestions),
	  -- and wms task type (2 for putaway).
	  UPDATE mtl_material_transactions_temp
	    SET move_order_line_id = v_mo_line.line_id
	    , completion_transaction_id = l_completion_txn_id
	    , item_primary_uom_code = l_primary_uom_code
	    , transaction_status = 2
	    , wms_task_type = 2
	    , operation_seq_num = l_operation_seq_num   --need these 2 columns when
	    , repetitive_line_id = l_repetitive_line_id --reverting crossdock
	    WHERE  transaction_temp_id = l_txn_temp_id;

	  IF (l_debug = 1) THEN
	     mydebug('Updated the MMTT record with additional info');
	  END IF;

	  l_progress := '90';

	  IF (v_mo_line.lot_number IS NOT NULL) THEN
	     -- Insert a record into MTLT
	     IF (l_debug = 1) THEN
		mydebug('Insert a record into MTLT for lot: ' || v_mo_line.lot_number);
	     END IF;

	     l_return :=
	       inv_trx_util_pub.insert_lot_trx
	       (p_trx_tmp_id     => l_txn_temp_id,
		p_user_id        => p_user_id,
		p_lot_number     => v_mo_line.lot_number,
		p_trx_qty        => v_mo_line.quantity,
		p_pri_qty        => v_mo_line.primary_quantity,
		x_ser_trx_id     => l_ser_trx_id,
		x_proc_msg       => x_msg_data,
		p_secondary_qty  => v_mo_line.SECONDARY_QUANTITY,
		p_secondary_uom  => v_mo_line.SECONDARY_UOM_CODE
		);

	     IF (l_debug = 1) THEN
		mydebug('Successfully inserted MTLT record');
	     END IF;

	     l_progress := '100';

	     IF (l_return <> 0) THEN
		IF (l_debug = 1) THEN
		   mydebug('Error occurred while calling inv_trx_util_pub.insert_lot_trx');
		END IF;

		RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	     -- Update the MTLT record to clear out the serial_transaction_temp_id column
	     -- since insert_lot_trx by default will insert a value for it.
	     UPDATE mtl_transaction_lots_temp
	       SET serial_transaction_temp_id = NULL
	       WHERE  transaction_temp_id = l_txn_temp_id;

	     IF (l_debug = 1) THEN
		mydebug('Cleared out the serial txn temp ID column in MTLT record');
	     END IF;

	     l_progress := '110';
	  END IF;


	  l_progress := '130';
       END LOOP; -- End mo_lines_cursor LOOP
    END LOOP; -- End nested_lpn_cursor LOOP
    CLOSE nested_lpn_cursor;


    -- Delete WDT
    FORALL i in 1..l_mmtt_id_tab.COUNT
      DELETE FROM wms_dispatched_tasks
      WHERE  transaction_temp_id = l_mmtt_id_tab(i)
      AND  task_type = 2;


    -- Delete MTLT
    FORALL i in 1..l_mmtt_id_tab.COUNT
      DELETE FROM mtl_transaction_lots_temp
      WHERE  transaction_temp_id = l_mmtt_id_tab(i);

    FOR i IN 1..l_mmtt_id_tab.COUNT LOOP
       UPDATE mtl_txn_request_lines
	 SET  quantity_detailed = Nvl(quantity_detailed,0)
	 -Decode(uom_code
		 ,l_mmtt_uom_tab(i)
		 ,l_mmtt_qty_tab(i)
		 ,inv_convert.inv_um_convert
		 (inventory_item_id
		  ,NULL
		  ,l_mmtt_qty_tab(i)
		  ,l_mmtt_uom_tab(i)
		  ,uom_code
		  ,NULL
		  ,NULL)
		 )
	 WHERE line_id = l_mmtt_mol_id_tab(i);
    END LOOP;

    -- Delete MMTT.
    FORALL i in 1..l_mmtt_id_tab.COUNT
      DELETE FROM mtl_material_transactions_temp
      WHERE transaction_temp_id = l_mmtt_id_tab(i);

    IF (l_debug = 1) THEN
       mydebug('Finished cleaning up old WDT, MTLT, and MMTT records');
    END IF;

    l_progress := '135';

    x_return_status := fnd_api.g_ret_sts_success;
    x_number_of_rows := l_number_of_rows;

    IF (l_debug = 1) THEN
      mydebug('Finished inserting suggestion records: ' || l_number_of_rows);
    END IF;

    l_progress := '140';


    -- Call the ATF API to insert WDTs
    -- Moved the ATF API calls to the complete_putaway_wrapper API instead.  -etam

    IF (l_debug = 1) THEN
      mydebug('***End of create_user_suggestions***');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_suggestions_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting create_user_suggestions - Execution error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_suggestions_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting create_user_suggestions - Unexpected error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO create_suggestions_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting create_user_suggestions - Others exception: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
  END create_user_suggestions;


  PROCEDURE validate_lot_serial_status(
    p_organization_id    IN             NUMBER
  , p_lpn_id             IN             NUMBER
  , x_return_status      OUT NOCOPY     VARCHAR2
  , x_msg_count          OUT NOCOPY     NUMBER
  , x_msg_data           OUT NOCOPY     VARCHAR2
  , x_validation_passed  OUT NOCOPY     VARCHAR2
  , x_invalid_value      OUT NOCOPY     VARCHAR2
  ) IS
    l_api_name   CONSTANT VARCHAR2(30) := 'validate_lot_serial_status';
    l_progress            VARCHAR2(10);
    l_item_id             NUMBER;
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
    l_lot_number          VARCHAR2(80);
    l_serial_number       VARCHAR2(30);
    l_transaction_type    NUMBER;
    l_lot_control_code    NUMBER;
    l_serial_control_code NUMBER;
    l_return              VARCHAR2(1);

    CURSOR l_item_txn_cursor IS
      SELECT inventory_item_id
           , lot_number
           , transaction_type_id
      FROM   mtl_txn_request_lines
      WHERE  organization_id = p_organization_id
      AND    lpn_id = p_lpn_id;

    CURSOR l_serial_cursor IS
      SELECT serial_number
      FROM   mtl_serial_numbers
      WHERE  inventory_item_id = l_item_id
      AND    current_organization_id = p_organization_id
      AND    lpn_id = p_lpn_id;

    l_debug               NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('***Calling validate_lot_serial_status***');
      mydebug('Org ID: => ' || p_organization_id);
      mydebug('LPN ID: => ' || p_lpn_id);
    END IF;

    -- Set the savepoint
    SAVEPOINT validate_status_sp;
    l_progress := '10';
    -- Initialize the return variable
    l_return := 'Y';
    -- Loop through each move order line for the LPN
    OPEN l_item_txn_cursor;

    LOOP
      FETCH l_item_txn_cursor INTO l_item_id, l_lot_number, l_transaction_type;
      EXIT WHEN l_item_txn_cursor%NOTFOUND;

      IF (l_debug = 1) THEN
        mydebug('Current move order line values:');
        mydebug('Inventory Item ID: ==> ' || l_item_id);
        mydebug('Lot Number: =========> ' || l_lot_number);
        mydebug('Transaction type: ===> ' || l_transaction_type);
      END IF;

      -- Get the item's lot and serial control code
      SELECT lot_control_code
           , serial_number_control_code
      INTO   l_lot_control_code
           , l_serial_control_code
      FROM   mtl_system_items
      WHERE  inventory_item_id = l_item_id
      AND    organization_id = p_organization_id;

      IF (l_debug = 1) THEN
        mydebug('Lot and serial control code: ' || l_lot_control_code || ', ' || l_serial_control_code);
      END IF;

      l_progress := '20';

      -- Check lot status if lot controlled
      IF (l_lot_control_code = 2) THEN
        -- Make sure that a lot number was stamped onto the move order line
        IF (l_lot_number IS NULL) THEN
          IF (l_debug = 1) THEN
            mydebug('No lot number on move order line!');
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        l_progress := '30';
        -- Check if the lot material status is valid
        -- for the current move order line's transaction type
        l_return :=
          inv_material_status_grp.is_status_applicable(
            p_wms_installed             => 'TRUE'
          , p_trx_status_enabled        => NULL
          , p_trx_type_id               => l_transaction_type
          , p_lot_status_enabled        => NULL
          , p_serial_status_enabled     => NULL
          , p_organization_id           => p_organization_id
          , p_inventory_item_id         => l_item_id
          , p_sub_code                  => NULL
          , p_locator_id                => NULL
          , p_lot_number                => l_lot_number
          , p_serial_number             => NULL
          , p_object_type               => 'O'
          );

        IF (l_debug = 1) THEN
          mydebug('Lot material status valid: ' || l_return);
        END IF;

        l_progress := '40';

        -- The function returned 'N' so the lot is not valid
        -- for the transaction type in the current move order line
        IF (l_return = 'N') THEN
          x_invalid_value := l_lot_number;
          EXIT;
        END IF;
      END IF;

      -- Check serial status if serial controlled
      IF (l_serial_control_code <> 1) THEN
        -- Loop through each serial for the item in the LPN
        OPEN l_serial_cursor;

        LOOP
          FETCH l_serial_cursor INTO l_serial_number;
          EXIT WHEN l_serial_cursor%NOTFOUND;

          IF (l_debug = 1) THEN
            mydebug('Current serial: ' || l_serial_number);
          END IF;

          l_progress := '50';
          -- Check if the serial material status is valid
          -- for the current move order line's transaction type
          l_return :=
            inv_material_status_grp.is_status_applicable(
              p_wms_installed             => 'TRUE'
            , p_trx_status_enabled        => NULL
            , p_trx_type_id               => l_transaction_type
            , p_lot_status_enabled        => NULL
            , p_serial_status_enabled     => NULL
            , p_organization_id           => p_organization_id
            , p_inventory_item_id         => l_item_id
            , p_sub_code                  => NULL
            , p_locator_id                => NULL
            , p_lot_number                => NULL
            , p_serial_number             => l_serial_number
            , p_object_type               => 'S'
            );

          IF (l_debug = 1) THEN
            mydebug('Serial material status valid: ' || l_return);
          END IF;

          l_progress := '60';

          -- The function returned 'N' so the serial is not valid
          -- for the transaction type in the current move order line
          IF (l_return = 'N') THEN
            x_invalid_value := l_serial_number;
            EXIT;
          END IF;
        END LOOP;

        CLOSE l_serial_cursor;

        -- If any one of the serials did not pass validation,
        -- exit the l_item_txn_cursor loop.  No further validation
        -- is required since validation has already failed.
        IF (l_return = 'N') THEN
          EXIT;
        END IF;
      END IF;
    END LOOP;

    CLOSE l_item_txn_cursor;

    -- Finished validating lot and serial statuses
    IF (l_debug = 1) THEN
      mydebug('Validation passed: ' || l_return);
      mydebug('Invalid value: ' || x_invalid_value);
    END IF;

    l_progress := '70';
    -- Set the output variable
    x_validation_passed := l_return;
    x_return_status := fnd_api.g_ret_sts_success;

    IF (l_debug = 1) THEN
      mydebug('***End of validate_lot_serial_status***');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO validate_status_sp;
      x_validation_passed := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting validate_lot_serial_status - Execution error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO validate_status_sp;
      x_validation_passed := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting validate_lot_serial_status - Unexpected error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO validate_status_sp;
      x_validation_passed := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug('Exiting validate_lot_serial_status - Others exception: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
  END validate_lot_serial_status;

  PROCEDURE revert_loc_suggested_capacity(
    x_return_status    OUT NOCOPY     VARCHAR2
  , x_msg_count        OUT NOCOPY     NUMBER
  , x_msg_data         OUT NOCOPY     VARCHAR2
  , p_organization_id  IN             NUMBER
  , p_lpn_id           IN             NUMBER
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'revert_loc_suggested_capacity';
    l_progress          VARCHAR2(10);
    l_item_id           NUMBER;
    l_locator_id        NUMBER;
    l_quantity          NUMBER;
    l_uom_code          VARCHAR2(3);
    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_parent_line_id    NUMBER; --6962664
    l_txn_header_id     NUMBER; --6962664

    -- Bug# 3434940 - Performance Fixes
    -- Cursor to retrieve the nested LPNs within a given outer LPN
    CURSOR nested_lpn_cursor IS
       SELECT lpn_id
	 FROM wms_license_plate_numbers
	 START WITH lpn_id = p_lpn_id
	 CONNECT BY PRIOR lpn_id = parent_lpn_id;
    l_current_lpn_id    NUMBER;

    -- Bug# 3434940 - Performance Fixes
    -- Take the CONNECT by clause out and use an outer cursor loop
    -- to get all of the nested LPNs
    CURSOR l_suggestions_cursor IS
     SELECT mmtt.inventory_item_id
       --BUG 3541045: For Inventory Move, suggested sub/loc will be stamped
       --on transfer_subinventory/transfer_to_location.  So, look at that
       --first.  Only if it is null should we use the locator_id
           , Nvl(mmtt.transfer_to_location,mmtt.locator_id) locator_id
           , mmtt.transaction_quantity
           , mmtt.transaction_uom
	   , mmtt.parent_line_id         --6962664
           , mmtt.transaction_header_id  --6962664
      FROM   mtl_material_transactions_temp mmtt,
             mtl_txn_request_lines mtrl
      WHERE  mmtt.move_order_line_id = mtrl.line_id
        AND  mmtt.organization_id = p_organization_id
        AND  mmtt.lpn_id = l_current_lpn_id
        AND  NVL(mmtt.wms_task_type, 0) <> -1;

  BEGIN
    IF (l_debug = 1) THEN
      mydebug('***Calling revert_loc_suggested_capacity***');
      mydebug('Org ID: => ' || p_organization_id);
      mydebug('LPN ID: => ' || p_lpn_id);
    END IF;

    -- Set the savepoint
    SAVEPOINT revert_capacity_sp;
    l_progress := '10';

    -- Bug# 3434940 - Performance Fixes
    -- Loop through the nested LPNs first
    OPEN nested_lpn_cursor;
    LOOP
       FETCH nested_lpn_cursor INTO l_current_lpn_id;
       EXIT WHEN nested_lpn_cursor%NOTFOUND;
       IF (l_debug = 1) THEN
	  mydebug('Current LPN ID: ' || l_current_lpn_id);
       END IF;

       -- Loop through each suggested MMTT line for the current LPN
       OPEN l_suggestions_cursor;
       LOOP
	  FETCH l_suggestions_cursor INTO l_item_id, l_locator_id, l_quantity, l_uom_code,l_parent_line_id,l_txn_header_id; --6962664 added last two variables
	  EXIT WHEN l_suggestions_cursor%NOTFOUND;
    --6962664 START
          mydebug('Locator id value is '|| l_locator_id);
          IF l_locator_id IS NULL THEN
          BEGIN
	  mydebug('Getting locator value using parent mmtt as locator value is null');
          SELECT locator_id INTO l_locator_id
          FROM mtl_material_transactions_temp
          WHERE transaction_temp_id = l_parent_line_id
          AND transaction_header_id = l_txn_header_id;

          EXCEPTION
          WHEN No_Data_Found THEN
          mydebug('The locator id could not be fetched  ');
          WHEN OTHERS THEN
          mydebug('Unknown Exception');
          END;
          END IF;
    --6962664  END

	  IF (l_debug = 1) THEN
	     mydebug('Current MMTT suggestion values:');
	     mydebug('Inventory Item ID: => ' || l_item_id);
	     mydebug('Locator ID: ========> ' || l_locator_id);
	     mydebug('Transaction qty: ===> ' || l_quantity);
	     mydebug('Transaction UOM: ===> ' || l_uom_code);
	  END IF;

	  l_progress := '20';

	  IF (l_debug = 1) THEN
	     mydebug('Call INV_LOC_WMS_UTILS.revert_loc_suggested_capacity API');
	  END IF;

	  inv_loc_wms_utils.revert_loc_suggested_capacity
	    (x_return_status             => x_return_status
	     , x_msg_count                 => x_msg_count
	     , x_msg_data                  => x_msg_data
	     , p_organization_id           => p_organization_id
	     , p_inventory_location_id     => l_locator_id
	     , p_inventory_item_id         => l_item_id
	     , p_primary_uom_flag          => 'N'
	     , p_transaction_uom_code      => l_uom_code
	     , p_quantity                  => l_quantity
	     );
	  l_progress := '30';

	  IF (x_return_status = fnd_api.g_ret_sts_success) THEN
	     IF (l_debug = 1) THEN
		mydebug('Success returned from revert_loc_suggested_capacity API');
	     END IF;
	   ELSE
	     IF (l_debug = 1) THEN
		mydebug('Failure returned from revert_loc_suggested_capacity API');
	     END IF;
	     -- Bug 5393727: do not raise an exception if revert API returns an error
	     -- RAISE fnd_api.g_exc_error;
	  END IF;

	  l_progress := '40';
       END LOOP;
       CLOSE l_suggestions_cursor;

    END LOOP;
    CLOSE nested_lpn_cursor;

    -- Set the output variable
    x_return_status := fnd_api.g_ret_sts_success;
    l_progress := '50';

    IF (l_debug = 1) THEN
      mydebug('***End of revert_loc_suggested_capacity***');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO revert_capacity_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug(
          'Exiting revert_loc_suggested_capacity - Execution error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        );
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO revert_capacity_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug(
          'Exiting revert_loc_suggested_capacity - Unexpected error: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO revert_capacity_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
        mydebug(
          'Exiting revert_loc_suggested_capacity - Others exception: ' || l_progress || ' '
          || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS')
        );
      END IF;
  END revert_loc_suggested_capacity;

  --{{
  -- Test the flow where check_for_crossdock is called
  --}}
  PROCEDURE check_for_crossdock(
    p_organization_id  IN             NUMBER
  , p_lpn_id           IN             NUMBER
  , x_return_status    OUT NOCOPY     VARCHAR2
  , x_msg_count        OUT NOCOPY     NUMBER
  , x_msg_data         OUT NOCOPY     VARCHAR2
  , x_crossdock        OUT NOCOPY     VARCHAR2
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'check_for_crossdock';
    l_progress          VARCHAR2(10);
    l_cross_dock_flag   NUMBER;
    l_ret_crossdock     NUMBER;
    l_debug             NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1) THEN
      mydebug('***Calling check_for_crossdock***');
      mydebug('Org ID: => ' || p_organization_id);
      mydebug('LPN ID: => ' || p_lpn_id);
    END IF;

    -- Set the savepoint
    SAVEPOINT check_crossdock_sp;
    l_progress := '10';

    x_crossdock := 'N';

    BEGIN
       SELECT 'Y'
	 INTO x_crossdock
	 FROM dual
	 WHERE exists
	 (SELECT 1
	  FROM mtl_txn_request_lines
	  WHERE lpn_id = p_lpn_id
	  AND organization_id = p_organization_id
	  AND backorder_delivery_detail_id IS NOT NULL);
    EXCEPTION
       WHEN OTHERS THEN
	  x_crossdock := 'N';
    END ;

/*
    -- Check to see if cross dock is enabled for the org
    SELECT NVL(crossdock_flag, 2)
    INTO   l_cross_dock_flag
    FROM   mtl_parameters
    WHERE  organization_id = p_organization_id;

    IF (l_debug = 1) THEN
      mydebug('Cross Dock Flag: ' || l_cross_dock_flag);
    END IF;

    l_progress := '20';

    IF (l_cross_dock_flag = 1) THEN
      IF (l_debug = 1) THEN
        mydebug('Crossdock is enabled so check for it');
      END IF;

      -- Call the cross dock API
      wms_cross_dock_pvt.crossdock(
        p_org_id            => p_organization_id
      , p_lpn               => p_lpn_id
      , x_ret               => l_ret_crossdock
      , x_return_status     => x_return_status
      , x_msg_count         => x_msg_count
      , x_msg_data          => x_msg_data
      );

      IF (l_debug = 1) THEN
        mydebug('Finished calling WMS_Cross_Dock_Pvt.crossdock API');
      END IF;

      l_progress := '30';
      -- See if there are any error messages returned from the API
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (x_msg_count = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('Successful');
        END IF;
      ELSIF(x_msg_count = 1) THEN
        IF (l_debug = 1) THEN
          mydebug('Not Successful');
          mydebug('Error message: ' || REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('Not Successful2');
        END IF;

        FOR i IN 1 .. x_msg_count LOOP
          x_msg_data := fnd_msg_pub.get(i, 'F');

          IF (l_debug = 1) THEN
            mydebug('Error messages: ' || REPLACE(x_msg_data, fnd_global.local_chr(0), ' '));
          END IF;
        END LOOP;
      END IF;

      l_progress := '40';

      -- Check the return status from the API call
      IF (x_return_status = fnd_api.g_ret_sts_success) THEN
        IF (l_debug = 1) THEN
          mydebug('Success returned from WMS_Cross_Dock_Pvt.crossdock API');
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          mydebug('Failure returned from WMS_Cross_Dock_Pvt.crossdock API');
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '50';

      -- Check the cross dock return value
      IF (l_ret_crossdock = 1) THEN
        IF (l_debug = 1) THEN
          mydebug('Nothing to Cross Dock');
        END IF;

        x_crossdock := 'N';
      ELSIF(l_ret_crossdock = 0) THEN
        IF (l_debug = 1) THEN
          mydebug('Cross Dock Succeeded');
        END IF;

        x_crossdock := 'Y';
      ELSE
        IF (l_debug = 1) THEN
          mydebug('Cross Dock Errored');
        END IF;

        x_crossdock := 'N';
      END IF;

      l_progress := '60';
    ELSE
      IF (l_debug = 1) THEN
        mydebug('Cross Dock is not enabled');
      END IF;

      x_crossdock := 'N';
    END IF;
*/
    -- Set the output variable
    x_return_status := fnd_api.g_ret_sts_success;
    l_progress := '70';

    IF (l_debug = 1) THEN
      mydebug('***End of check_for_crossdock***');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO check_crossdock_sp;
      x_crossdock := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
	 mydebug('Exiting check_for_crossdock - Execution error: ' ||
		 l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO check_crossdock_sp;
      x_crossdock := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
	 mydebug('Exiting check_for_crossdock - Unexpected error: ' ||
		 l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO check_crossdock_sp;
      x_crossdock := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

      IF (l_debug = 1) THEN
	 mydebug('Exiting check_for_crossdock - Others exception: ' ||
		 l_progress || ' ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
  END check_for_crossdock;


END wms_task_dispatch_put_away;

/

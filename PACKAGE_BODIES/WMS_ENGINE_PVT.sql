--------------------------------------------------------
--  DDL for Package Body WMS_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ENGINE_PVT" AS
  /* $Header: WMSVPPEB.pls 120.11.12010000.11 2010/04/29 18:46:42 mchemban ship $ */
  --
  -- File        : WMSVPPEB.pls
  -- Content     : WMS_Engine_PVT package body
  -- Description : wms rules engine private API's
  -- Notes       :
  -- Modified    : 30/10/98 ckuenzel created orginal file in inventory
  --               02/08/99 mzeckzer changed
  --               07/31/99 bitang   created in wms
  --               05/12/05 grao     added logic for rule search - 'K'
  --
  g_pkg_name 	CONSTANT VARCHAR2(30) := 'WMS_Engine_PVT';
  g_debug    	NUMBER;
  g_use_rule 	VARCHAR2(1) := 'Y' ;
  -- [g_use_rule 	VARCHAR2(1) := 'Y'; used to track if stg/rule
  -- search API is required to be called or not ]

  --
  SUBTYPE g_wms_txn_temp_rec_type IS wms_transactions_temp%ROWTYPE;

  TYPE g_wms_txn_temp_tbl_type IS TABLE OF g_wms_txn_temp_rec_type
    INDEX BY BINARY_INTEGER;

  -- a record type used in the combine_transfer procedure
  TYPE g_combine_rec_type IS RECORD(
    revision                   wms_transactions_temp.revision%TYPE
  , from_subinventory_code     wms_transactions_temp.from_subinventory_code%TYPE
  , from_locator_id            wms_transactions_temp.from_locator_id%TYPE
  , from_cost_group_id         wms_transactions_temp.from_cost_group_id%TYPE
  , to_subinventory_code       wms_transactions_temp.to_subinventory_code%TYPE
  , to_locator_id              wms_transactions_temp.to_locator_id%TYPE
  , to_cost_group_id           wms_transactions_temp.to_cost_group_id%TYPE
  , lot_number                 wms_transactions_temp.lot_number%TYPE
  , lot_expiration_date        wms_transactions_temp.lot_expiration_date%TYPE
  , serial_number              wms_transactions_temp.serial_number%TYPE
  , transaction_quantity       wms_transactions_temp.transaction_quantity%TYPE
  , primary_quantity           wms_transactions_temp.primary_quantity%TYPE
  , secondary_quantity         wms_transactions_temp.secondary_quantity%TYPE
  , grade_code                 wms_transactions_temp.grade_code%TYPE
  , rule_id                    wms_transactions_temp.rule_id%TYPE
  , reservation_id             wms_transactions_temp.reservation_id%TYPE
  , lpn_id                     wms_transactions_temp.lpn_id%TYPE);

  TYPE g_combine_tbl_type IS TABLE OF g_combine_rec_type
    INDEX BY BINARY_INTEGER;

  --
  --Procedures for logging messages
  PROCEDURE log_event(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);

  BEGIN
    --l_progress := l_progress + 10;
    l_module:= 'wms.plsql.'||g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
    /*
    fnd_log.STRING(log_level => fnd_log.level_event,
                      module => l_module, message => p_message);
    gmi_reservation_util.println(p_message); */
  END log_event;

  PROCEDURE log_error(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module:= 'wms.plsql.'||g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);

    /*fnd_log.STRING(log_level => fnd_log.level_error,
                      module => l_module, message => p_message);
     gmi_reservation_util.println(p_message);*/
  END log_error;

  PROCEDURE log_error_msg(p_api_name VARCHAR2, p_label VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN
    l_module:= 'wms.plsql.'|| g_pkg_name ||'.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_label, l_module, 9);
    /*
    fnd_log.message(log_level => fnd_log.level_error,
                       module => l_module, pop_message => FALSE);
    inv_log_util.trace(p_label, l_module, 9);
    gmi_reservation_util.println(p_label); */
  END log_error_msg;

  PROCEDURE log_procedure(p_api_name VARCHAR2
                        , p_label VARCHAR2
                        , p_message VARCHAR2) IS
    l_module VARCHAR2(255);
  BEGIN

    l_module:= 'wms.plsql.'||g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, l_module, 9);
    /*
    fnd_log.STRING(log_level => fnd_log.level_procedure,
                      module => l_module, message => p_message);
    inv_log_util.trace(p_message, l_module, 9);
    gmi_reservation_util.println(p_message);*/
  END log_procedure;

  PROCEDURE log_statement(p_api_name VARCHAR2, p_label VARCHAR2, p_message VARCHAR2) IS
      l_module VARCHAR2(255);
   BEGIN
      l_module  := 'wms.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
      inv_log_util.trace(p_message, l_module, 9);
      /*
      fnd_log.STRING(log_level => fnd_log.level_statement, module => l_module, message => p_message);
      IF inv_pp_debug.is_debug_mode THEN
        inv_pp_debug.send_message_to_pipe(p_message);
      END IF;
      inv_log_util.trace(p_message, l_module, 9);
    gmi_reservation_util.println(p_message); */
  END log_statement;


  -- Description
  --   Insert all records in p_wms_txn_temp_tbl into wms_transactions_temp.
  --   Value for column pp_transaction_temp_id will be derived in the
  --   procedure
  --
  PROCEDURE insert_detail_temp_records
  ( x_return_status OUT NOCOPY VARCHAR2
  , p_wms_txn_temp_tbl IN g_wms_txn_temp_tbl_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(30)      := 'insert_detail_temp_records';
    l_debug NUMBER;

    --
   /* Bug 5265024
    CURSOR l_wms_txn_temp_id_csr IS
      SELECT wms_transactions_temp_s.NEXTVAL
        FROM DUAL;
  */

    l_wms_txn_temp_tbl_size NUMBER;
    l_temp_id_tbl           g_number_tbl_type;
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start Insert_Detail_temp_records');
    END IF;

    -- Initialize API return status to access
    x_return_status          := fnd_api.g_ret_sts_success;
    --
    l_wms_txn_temp_tbl_size  := p_wms_txn_temp_tbl.COUNT;

    -- return if nothing to insert
    IF l_wms_txn_temp_tbl_size IS NULL
       OR l_wms_txn_temp_tbl_size < 1 THEN
      RETURN;
    END IF;

    -- get pp_transaction_temp_id for all records
   /* Bug 5265024
    FOR l_counter IN 1 .. l_wms_txn_temp_tbl_size LOOP
      OPEN l_wms_txn_temp_id_csr;
      FETCH l_wms_txn_temp_id_csr INTO l_temp_id_tbl(l_counter);

      IF l_wms_txn_temp_id_csr%NOTFOUND THEN
        CLOSE l_wms_txn_temp_id_csr;
        RAISE NO_DATA_FOUND;
      END IF;

      CLOSE l_wms_txn_temp_id_csr;
    END LOOP;
   */

    -- insert to the table
    FOR l_counter IN 1 .. l_wms_txn_temp_tbl_size LOOP
      INSERT INTO wms_transactions_temp
                  (
                  pp_transaction_temp_id
                , transaction_temp_id
                , type_code
                , line_type_code
                , transaction_quantity
                , primary_quantity
                , secondary_quantity
                , grade_code
                , revision
                , lot_number
                , lot_expiration_date
                , serial_number
                , from_subinventory_code
                , from_locator_id
                , rule_id
                , reservation_id
                , to_subinventory_code
                , to_locator_id
                , from_organization_id
                , to_organization_id
                , from_cost_group_id
                , to_cost_group_id
                , lpn_id
                  )
           VALUES (
                  wms_transactions_temp_s.NEXTVAL
               --   l_temp_id_tbl(l_counter)
                , p_wms_txn_temp_tbl(l_counter).transaction_temp_id
                , p_wms_txn_temp_tbl(l_counter).type_code
                , p_wms_txn_temp_tbl(l_counter).line_type_code
                , p_wms_txn_temp_tbl(l_counter).transaction_quantity
                , p_wms_txn_temp_tbl(l_counter).primary_quantity
                , p_wms_txn_temp_tbl(l_counter).secondary_quantity
                , p_wms_txn_temp_tbl(l_counter).grade_code
                , p_wms_txn_temp_tbl(l_counter).revision
                , p_wms_txn_temp_tbl(l_counter).lot_number
                , p_wms_txn_temp_tbl(l_counter).lot_expiration_date
                , p_wms_txn_temp_tbl(l_counter).serial_number
                , p_wms_txn_temp_tbl(l_counter).from_subinventory_code
                , p_wms_txn_temp_tbl(l_counter).from_locator_id
                , p_wms_txn_temp_tbl(l_counter).rule_id
                , p_wms_txn_temp_tbl(l_counter).reservation_id
                , p_wms_txn_temp_tbl(l_counter).to_subinventory_code
                , p_wms_txn_temp_tbl(l_counter).to_locator_id
                , p_wms_txn_temp_tbl(l_counter).from_organization_id
                , p_wms_txn_temp_tbl(l_counter).to_organization_id
                , p_wms_txn_temp_tbl(l_counter).from_cost_group_id
                , p_wms_txn_temp_tbl(l_counter).to_cost_group_id
                , p_wms_txn_temp_tbl(l_counter).lpn_id
                  );
       IF l_debug = 1 THEN
          log_event(l_api_name, 'detail temp insert ', 'detail temp insert '
                          || p_wms_txn_temp_tbl(l_counter).secondary_quantity);
       END IF;
    END LOOP;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End Insert_Detail_temp_records');
    END IF;
   --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
     /* bug 5265024
      IF l_wms_txn_temp_id_csr%ISOPEN THEN
        CLOSE l_wms_txn_temp_id_csr;
      END IF;
     * /
      x_return_status  := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error in Insert_Detail_temp_records');
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      /* bug 5265024
      IF l_wms_txn_temp_id_csr%ISOPEN THEN
        CLOSE l_wms_txn_temp_id_csr;
      END IF;
      */
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error',
                    'Unexpected error in Insert_Detail_temp_records');
      END IF;
    --
    WHEN OTHERS THEN
      /*bug 5265024
      IF l_wms_txn_temp_id_csr%ISOPEN THEN
        CLOSE l_wms_txn_temp_id_csr;
      END IF;
      */

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error',
		'Other error in Insert_Detail_temp_records');
      END IF;
  END insert_detail_temp_records;

  --
  -- Description
  --   Purges all records from WMS_TRANSACTIONS_TEMP for the move
  --   order line
  PROCEDURE purge_detail_temp_records
  ( x_return_status OUT NOCOPY VARCHAR2
  , p_request_line_rec IN inv_detail_util_pvt.g_request_line_rec_type
  ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'purge_detail_temp_records';
    l_debug NUMBER;
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
          g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
     END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start purge_detail_temp_records');
    END IF;

    -- Initialisize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    --
    DELETE FROM wms_transactions_temp
          WHERE transaction_temp_id = p_request_line_rec.line_id;

    --
    DELETE FROM wms_txn_context_temp
          WHERE line_id = p_request_line_rec.line_id;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End purge_detail_temp_records');
    END IF;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error in purge_detail_temp_records');
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error in purge_detail_temp_records');
      END IF;
    --
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error in purge_detail_temp_records');
      END IF;
  --
  END purge_detail_temp_records;

  --
  -- Description
  --   For future serial number support
  --   Resolves serial number ranges and insert records into the temporary table
  --   for detailing
  PROCEDURE resolve_serials(
    x_return_status    OUT NOCOPY    VARCHAR2
  , p_request_line_rec IN            inv_detail_util_pvt.g_request_line_rec_type
  , p_request_context  IN            inv_detail_util_pvt.g_request_context_rec_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(30)            := 'resolve_serials';
    l_return_status         VARCHAR2(1)             := fnd_api.g_ret_sts_success;
    --
    l_counter               INTEGER;
    l_prefix                VARCHAR2(30);
    l_fm_num                VARCHAR2(30);
    l_to_num                VARCHAR2(30);
    l_length_num            INTEGER;
    l_counter               INTEGER;
    l_wms_txn_temp_tbl      g_wms_txn_temp_tbl_type;
    l_wms_txn_temp_tbl_size NUMBER;
    l_debug                 NUMBER;
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
           g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start resolve_serials');
    END IF;
    --
    -- Initialisize API return status to access
    x_return_status  := fnd_api.g_ret_sts_success;

    --
    -- get the actual serial number based on range
    IF  p_request_line_rec.serial_number_end IS NOT NULL
        AND p_request_line_rec.serial_number_end <> p_request_line_rec.serial_number_start THEN
      inv_detail_util_pvt.split_prefix_num(p_request_line_rec.serial_number_start, l_prefix, l_fm_num);
      inv_detail_util_pvt.split_prefix_num(p_request_line_rec.serial_number_end, l_prefix, l_to_num);
      l_length_num             := LENGTH(l_fm_num);

      --
      FOR l_counter IN 1 .. l_to_num - l_fm_num + 1 LOOP
        --need to find out how to deal with this
        --for multi-language purpose
        l_wms_txn_temp_tbl(l_counter).serial_number  := l_prefix || LPAD(TO_CHAR(l_fm_num + l_counter), l_length_num, '0');

        -- if l_debug = 1 then
        -- log_statement(l_api_name, 'resolve_serials', l_wms_txn_temp_tbl(l_counter).serial_number );
        -- end if;
      END LOOP;

      l_wms_txn_temp_tbl_size  := l_to_num - l_fm_num + 1;
    ELSE
      -- Insert record for single serial number into wms_transactions_temp
      l_wms_txn_temp_tbl(1).serial_number  := p_request_line_rec.serial_number_start;
      l_wms_txn_temp_tbl_size              := 1;
    END IF;

    -- taking care of other fields
    FOR l_counter IN 1 .. l_wms_txn_temp_tbl_size LOOP
      l_wms_txn_temp_tbl(l_counter).transaction_temp_id     := p_request_line_rec.line_id;
      l_wms_txn_temp_tbl(l_counter).type_code               := p_request_context.type_code;
      l_wms_txn_temp_tbl(l_counter).line_type_code          := 1;
      l_wms_txn_temp_tbl(l_counter).transaction_quantity    := 1;
      l_wms_txn_temp_tbl(l_counter).primary_quantity        := 1;
      l_wms_txn_temp_tbl(l_counter).revision                := p_request_line_rec.revision;
      l_wms_txn_temp_tbl(l_counter).lot_number              := p_request_line_rec.lot_number;
      l_wms_txn_temp_tbl(l_counter).lot_expiration_date     := p_request_context.lot_expiration_date;
      l_wms_txn_temp_tbl(l_counter).from_subinventory_code  := p_request_line_rec.from_subinventory_code;
      l_wms_txn_temp_tbl(l_counter).from_locator_id         := p_request_line_rec.from_locator_id;
      l_wms_txn_temp_tbl(l_counter).to_subinventory_code    := p_request_line_rec.to_subinventory_code;
      l_wms_txn_temp_tbl(l_counter).to_locator_id           := p_request_line_rec.to_locator_id;
      l_wms_txn_temp_tbl(l_counter).from_organization_id    := p_request_line_rec.organization_id;
      l_wms_txn_temp_tbl(l_counter).to_organization_id      := p_request_line_rec.to_organization_id;
      l_wms_txn_temp_tbl(l_counter).from_cost_group_id      := p_request_line_rec.from_cost_group_id;
      l_wms_txn_temp_tbl(l_counter).to_cost_group_id        := p_request_line_rec.to_cost_group_id;
    END LOOP;

    --
    x_return_status  := l_return_status;

   IF l_debug = 1 THEN
      log_procedure(l_api_name, 'end', 'End resolve_serials');
   END IF;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error in resolve_serials');
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      If l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error in resolve_serials');
      END IF;
    --
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error in resolve_serials');
      END IF;
  --
  END resolve_serials;

  --
  -- Procedure : Prepare
  -- FUNCTION  : Creates records in WMS_TRANSACTIONS_TEMP for
  --             each single lot and/or serial number and splits
  --             transfer transactions into issue and receipt
  --             transaction
  PROCEDURE prepare(
    x_return_status           OUT NOCOPY    VARCHAR2
  , p_request_line_rec        IN            inv_detail_util_pvt.g_request_line_rec_type
  , p_request_context         IN            inv_detail_util_pvt.g_request_context_rec_type
  , p_reservations            IN            inv_reservation_global.mtl_reservation_tbl_type
  , x_allow_non_partial_rules OUT NOCOPY    BOOLEAN
  ) IS
    l_api_name       CONSTANT VARCHAR2(30)                                := 'Prepare';
    l_return_status           VARCHAR2(1)                                 := fnd_api.g_ret_sts_success;
    l_sum_qty                 NUMBER                                      := 0;
    l_trx_qty                 NUMBER;
    -- For serial number support in the future
    l_serial_support          VARCHAR2(1)                                 := 'N';
    l_length_num              NUMBER;
    l_fm_num                  NUMBER;
    l_to_num                  NUMBER;
    l_counter                 NUMBER;
    l_subinventory_code       VARCHAR2(10);
    l_locator_id              NUMBER;
    l_remain_pri_qty          NUMBER;
    l_pp_temp_qty             NUMBER;
    l_reserved_qty            NUMBER;
    l_index                   NUMBER;
    --
    l_detail_level_tbl        inv_detail_util_pvt.g_detail_level_tbl_type;
    l_detail_level_tbl_size   NUMBER;
    --
    l_wms_txn_temp_tbl        g_wms_txn_temp_tbl_type;
    l_remaining_quantity      NUMBER;
    l_allow_non_partial_rules BOOLEAN;
    l_debug                   NUMBER;
    l_rsv_ctr                 NUMBER;  -- [ Added to track number of detailed serial numbers ]
  --
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start Prepare');
    END IF;

    -- Initialisize API return status to access
    x_return_status  := fnd_api.g_ret_sts_success;

    --
    -- check serial number control and support
    IF l_debug =1 then
       log_statement(l_api_name,'p_request_context.item_serial_control_code ', p_request_context.item_serial_control_code);
       log_statement(l_api_name,'l_serial_support ', l_serial_support);
       log_event(l_api_name, 'prepare', 'prepare' );
    END IF;

    IF  p_request_context.item_serial_control_code IN (2, 5, 6)
        AND l_serial_support = 'Y' THEN
      --
      -- Resolve FM_SERIAL_number and TO_SERIAL_number
      -- and insert one record for
      -- each serial number into WMS_TRANSACTION_TEMP
      --
      -- Here we assume that the number of serial numbers in the
      -- range and the transaction_quantity are the same
      --
      -- Important!!!!!!
      -- Currently this program does not handle the case that
      -- requires both serial number support and detail based on
      -- reservations. So you can not just change the value of
      -- l_serial_support to Y and expect the code will work correctly!
      --
      -- The fuctionality in inv_detail_util_pvt for detailing serial
      -- numbers is different from what I mean here. Over there
      -- we do not use any pick and put away rules, just check
      -- which serial number is free and take it. Here when we
      -- say detailing serial numbers, we mean we will check the
      -- rules defined by users and rules can specify constraints
      -- or sort preferences using serial number attributes
      --
      --     Bin Tang 10/20/1999
      --

       IF l_debug = 1 THEN
          log_statement(l_api_name ,  'Calling resolve_serials() ', '');
       END IF;
       resolve_serials(l_return_status, p_request_line_rec, p_request_context);
       IF l_return_status = fnd_api.g_ret_sts_error THEN
          RAISE fnd_api.g_exc_error;
       END IF;
       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
    ELSE
      IF p_request_context.transfer_flag
         OR p_request_context.type_code = 2 THEN -- pick only or transfer
        inv_detail_util_pvt.compute_pick_detail_level(
          		l_return_status
        		, p_request_line_rec
        		, p_request_context
       			, p_reservations
        		, l_detail_level_tbl
        		, l_detail_level_tbl_size
       			, l_remaining_quantity
        	      	);

        -- Bug # 2286454 ----
        --
        IF (l_remaining_quantity > 0) THEN
          l_allow_non_partial_rules  := FALSE;
        ELSE
          l_allow_non_partial_rules  := TRUE;
        END IF;

        x_allow_non_partial_rules  := l_allow_non_partial_rules;

        --
        IF l_debug = 1 THEN
           log_event(l_api_name, 'prepare ',  'prepare  detail_level_tbl_size '||l_detail_level_tbl_size);
        END IF;

        l_rsv_ctr := 0 ;  -- [ reset the rsv_counter ]

        FOR l_index IN 1 .. l_detail_level_tbl_size LOOP
          l_wms_txn_temp_tbl(l_index).transaction_temp_id     := p_request_line_rec.line_id;
          l_wms_txn_temp_tbl(l_index).type_code               := p_request_context.type_code;
          l_wms_txn_temp_tbl(l_index).line_type_code          := 1; -- input
          l_wms_txn_temp_tbl(l_index).transaction_quantity    := l_detail_level_tbl(l_index).transaction_quantity;
          l_wms_txn_temp_tbl(l_index).primary_quantity        := l_detail_level_tbl(l_index).primary_quantity;
          l_wms_txn_temp_tbl(l_index).secondary_quantity      := l_detail_level_tbl(l_index).secondary_quantity;
          l_wms_txn_temp_tbl(l_index).grade_code              := l_detail_level_tbl(l_index).grade_code;
          l_wms_txn_temp_tbl(l_index).revision                := l_detail_level_tbl(l_index).revision;
          l_wms_txn_temp_tbl(l_index).lot_number              := l_detail_level_tbl(l_index).lot_number;
          --log_event(l_api_name, 'prepare ',  'in prepare sec qty  '||l_detail_level_tbl(l_index).secondary_quantity);

          IF l_wms_txn_temp_tbl(l_index).lot_number IS NOT NULL THEN
            l_wms_txn_temp_tbl(l_index).lot_expiration_date  :=
               inv_detail_util_pvt.get_lot_expiration_date(
                  		   p_request_line_rec.organization_id
               			 , p_request_line_rec.inventory_item_id
                		 , l_wms_txn_temp_tbl(l_index).lot_number
               			);
          END IF;

          l_wms_txn_temp_tbl(l_index).from_organization_id    := p_request_line_rec.organization_id;
          l_wms_txn_temp_tbl(l_index).to_organization_id      := p_request_line_rec.to_organization_id;
          l_wms_txn_temp_tbl(l_index).from_cost_group_id      := p_request_line_rec.from_cost_group_id;
          l_wms_txn_temp_tbl(l_index).to_cost_group_id        := p_request_line_rec.to_cost_group_id;
          l_wms_txn_temp_tbl(l_index).from_subinventory_code  := l_detail_level_tbl(l_index).subinventory_code;
          l_wms_txn_temp_tbl(l_index).from_locator_id         := l_detail_level_tbl(l_index).locator_id;
          l_wms_txn_temp_tbl(l_index).to_subinventory_code    := p_request_line_rec.to_subinventory_code;
          l_wms_txn_temp_tbl(l_index).to_locator_id           := p_request_line_rec.to_locator_id;
          l_wms_txn_temp_tbl(l_index).reservation_id          := l_detail_level_tbl(l_index).reservation_id;
          l_wms_txn_temp_tbl(l_index).serial_number           := l_detail_level_tbl(l_index).serial_number; --- [ new code ]
          l_wms_txn_temp_tbl(l_index).lpn_id                  := l_detail_level_tbl(l_index).lpn_id;

          --[  Seting the flag to determine , if strategy/rule search API will be called or not ]
            IF l_detail_level_tbl(l_index).serial_resv_flag = 'Y' THEN
               l_rsv_ctr := l_rsv_ctr + 1;
            END IF;

          IF l_debug = 1 THEN
             log_event(l_api_name, 'prepare ',  'serial_number '||l_detail_level_tbl(l_index).serial_number);
             log_event(l_api_name, 'prepare ',  'serial_resv_flag '||l_detail_level_tbl(l_index).serial_resv_flag);
	     log_event(l_api_name, 'prepare ',  'p_request_line_rec.line_id '||p_request_line_rec.line_id);
	     log_event(l_api_name, 'prepare ',  'p_request_context.type_code '||p_request_context.type_code);
	     log_event(l_api_name, 'prepare ',  'transaction_quantity '||l_detail_level_tbl(l_index).transaction_quantity);
	     log_event(l_api_name, 'prepare ',  'locator_id '||l_detail_level_tbl(l_index).locator_id);
	     log_event(l_api_name, 'prepare ',  'reservation_id '||l_detail_level_tbl(l_index).reservation_id);
	  END IF;

        END LOOP;
        -- [  setting the  rule_use flag
	IF l_detail_level_tbl_size = l_rsv_ctr THEN
	   g_use_rule :=  'N' ;
	ELSE
	   g_use_rule :=  'Y' ;
        END IF;
        IF l_debug = 1 THEN
           log_event(l_api_name, 'prepare ',  'l_rsv_ctr  '|| l_rsv_ctr);
           log_event(l_api_name, 'prepare ',  'g_use_rule '|| g_use_rule);
        END IF;
        -- ]

      ELSE -- the request is for put away only
        l_wms_txn_temp_tbl(1).from_organization_id    := p_request_line_rec.organization_id;
        l_wms_txn_temp_tbl(1).to_organization_id      := p_request_line_rec.to_organization_id;
        l_wms_txn_temp_tbl(1).from_subinventory_code  := p_request_line_rec.from_subinventory_code;
        l_wms_txn_temp_tbl(1).from_locator_id         := p_request_line_rec.from_locator_id;
        l_wms_txn_temp_tbl(1).to_subinventory_code    := p_request_line_rec.to_subinventory_code;
        l_wms_txn_temp_tbl(1).to_locator_id           := p_request_line_rec.to_locator_id;
        l_wms_txn_temp_tbl(1).from_cost_group_id      := p_request_line_rec.from_cost_group_id;
        l_wms_txn_temp_tbl(1).to_cost_group_id        := p_request_line_rec.to_cost_group_id;
        l_wms_txn_temp_tbl(1).transaction_temp_id     := p_request_line_rec.line_id;
        l_wms_txn_temp_tbl(1).type_code               := p_request_context.type_code;
        l_wms_txn_temp_tbl(1).line_type_code          := 1; -- input
        l_wms_txn_temp_tbl(1).primary_quantity        := p_request_line_rec.primary_quantity;
        l_wms_txn_temp_tbl(1).secondary_quantity      := p_request_line_rec.secondary_quantity;
        l_wms_txn_temp_tbl(1).grade_code              := p_request_line_rec.grade_code;
        l_wms_txn_temp_tbl(1).transaction_quantity    := p_request_line_rec.quantity - NVL(p_request_line_rec.quantity_detailed, 0);
        l_wms_txn_temp_tbl(1).revision                := p_request_line_rec.revision;
        l_wms_txn_temp_tbl(1).lot_number              := p_request_line_rec.lot_number;
        l_wms_txn_temp_tbl(1).lot_expiration_date     := p_request_context.lot_expiration_date;
        l_wms_txn_temp_tbl(1).lpn_id                  := p_request_line_rec.lpn_id;
        -- Bug #2286454
        l_allow_non_partial_rules                     := TRUE;
      END IF;
      --
      -- now we can insert these temporary records derived from
      -- above
      insert_detail_temp_records(l_return_status, l_wms_txn_temp_tbl);
      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;
      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End Prepare');
    END IF;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
     /* --
      -- debugging section
      -- can be commented out for final code
      IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(SQLERRM);
        inv_pp_debug.send_message_to_pipe('exception in '|| l_api_name);
        inv_pp_debug.send_last_error_message;
      END IF;

      -- end of debugging section
      -- */
      x_return_status  := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error in Prepare');
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
     /* --
      -- debugging section
      -- can be commented out for final code
      IF inv_pp_debug.is_debug_mode THEN
        -- Note: in debug mode, later call to fnd_msg_pub.get will not get
        -- the message retrieved here since it is no longer on the stack
        inv_pp_debug.set_last_error_message(SQLERRM);
        inv_pp_debug.send_message_to_pipe('exception in '|| l_api_name);
        inv_pp_debug.send_last_error_message;
      END IF;

      -- end of debugging section
      -- */
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error in Prepare');
      END IF;
    --
    WHEN OTHERS THEN

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error in Prepare');
      END IF;
  --
  END prepare;

  --
  --
  -- Procedure : Prepare_Transfer_Receipt
  -- Pre-reqs  : Record(s) exist(s) in WMS_TRANSACTIONS_TEMP with
  --             p_transaction_temp_id = the move order line id
  --             and type_code = 2 (pick) and
  --             line_type_code = 2 (output line)
  -- Function  : Copies issue output record(s) into
  --             WMS_TRANSACTIONS_TEMP as input records
  --             for receipt portion within transfer transactions
  --
  PROCEDURE prepare_transfer_receipt
  (
    x_return_status    IN OUT NOCOPY VARCHAR2
  , p_request_line_rec IN            inv_detail_util_pvt.g_request_line_rec_type
  , p_request_context  IN            inv_detail_util_pvt.g_request_context_rec_type
  ) IS
    l_api_name     CONSTANT VARCHAR2(30)              := 'prepare_transfer_receipt';
    l_return_status         VARCHAR2(1)               := fnd_api.g_ret_sts_success;

    --
    --changed by jcearley on 12/8/99 to attempt to order transfers
    -- in order of pick suggestions

    CURSOR l_put_input_csr IS
      SELECT   SUM(wtt.transaction_quantity) transaction_quantity
             , SUM(wtt.primary_quantity) primary_quantity
             , SUM(wtt.secondary_quantity) secondary_quantity
             , wtt.grade_code grade_code
             , wtt.revision revision
             , wtt.lot_number lot_number
             , wtt.from_subinventory_code from_subinventory_code
             , wtt.from_locator_id from_locator_id
             , wtt.from_cost_group_id from_cost_group_id
             , wtt.lpn_id lpn_id
          FROM wms_transactions_temp wtt
         WHERE wtt.transaction_temp_id = p_request_line_rec.line_id
           AND wtt.line_type_code = 2 -- output line
           AND wtt.type_code = 2 -- pick
      GROUP BY wtt.lot_number
             , wtt.revision
             , wtt.from_subinventory_code
             , wtt.from_locator_id
             , wtt.from_cost_group_id
             , wtt.lpn_id
             , wtt.grade_code
      ORDER BY MIN(wtt.pp_transaction_temp_id);

    --
    l_put_input_rec         l_put_input_csr%ROWTYPE;
    --
    l_txn_qty               NUMBER;
    l_wms_txn_temp_tbl      g_wms_txn_temp_tbl_type;
    l_wms_txn_temp_tbl_size NUMBER;
    l_debug                 NUMBER;

	-- Added for Bug 6063903
    l_wms_installed BOOLEAN := TRUE;
    x_api_return_status VARCHAR2(2);
    x_msg_count       NUMBER;
    x_msg_data       VARCHAR2(2000);
	-- Added for Bug 6063903

  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start prepare_transfer_receipt');
    END IF;

    --
    -- Initialisize API return status to access
    x_return_status          := fnd_api.g_ret_sts_success;
    --
    l_wms_txn_temp_tbl_size  := 0;
    -- the fetching might be changed to use bulk
    -- fetching if it is too slow
    -- however, a disadvantage is that bulk fetching can
    -- not use table of record. that will make the code
    -- looks ugly
    OPEN l_put_input_csr;

    LOOP
      FETCH l_put_input_csr INTO l_put_input_rec;
      EXIT WHEN l_put_input_csr%NOTFOUND;
      -- Note: serial number here is ignored here. The assumption
      -- is that the put away side will not care about the serial number.
      -- The purpose is to reduce the number of records as input in
      -- wms_transactions_temp for put away since the more records
      -- it is, the more runs the engine has to run, and thus the slower.
      -- The assumption stated might not be valid for some situations.
      -- So this might need to be enhanced later.
      l_wms_txn_temp_tbl_size                                             := l_wms_txn_temp_tbl_size + 1;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).transaction_temp_id     := p_request_line_rec.line_id;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).type_code               := 1;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).line_type_code          := 1;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).transaction_quantity    := l_put_input_rec.transaction_quantity;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).primary_quantity        := l_put_input_rec.primary_quantity;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).secondary_quantity      := l_put_input_rec.secondary_quantity;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).grade_code              := l_put_input_rec.grade_code;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).revision                := l_put_input_rec.revision;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).lot_number              := l_put_input_rec.lot_number;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).lot_expiration_date     := p_request_context.lot_expiration_date;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).serial_number           := NULL;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).from_subinventory_code  := l_put_input_rec.from_subinventory_code;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).from_locator_id         := l_put_input_rec.from_locator_id;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).from_cost_group_id      := l_put_input_rec.from_cost_group_id;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).to_subinventory_code    := p_request_line_rec.to_subinventory_code;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).to_locator_id           := p_request_line_rec.to_locator_id;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).from_organization_id    := p_request_line_rec.organization_id;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).to_organization_id      := p_request_line_rec.to_organization_id;
      l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).lpn_id                  := l_put_input_rec.lpn_id;

      IF l_debug = 1 THEN
	      log_event(l_api_name, 'transfer and receipt input',  'transfer and receipt input');
	      log_event(l_api_name, 'transfer and receipt input',  'input qty1 '||
			 l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).primary_quantity );
	      log_event(l_api_name, 'transfer and receipt input',  'input qty2 '||
			 l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).secondary_quantity );
	      log_event(l_api_name, 'transfer and receipt input',  'input grade_code '||
			 l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).secondary_quantity );
      END IF;

-- Added for Bug 6063903
/*
    we are setting the l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).to_cost_group_id as Null
     as in inventory organization, cost group of Subinventory can be different from cost
     group of desitnation subivnentory. Correct CG will get populated at a later stage.
*/
  l_wms_installed :=   WMS_INSTALL.check_install(
	                                    x_return_status   => x_api_return_status,
	                                    x_msg_count       => x_msg_count,
	                                    x_msg_data        => x_msg_data,
	                                     p_organization_id => p_request_line_rec.organization_id);

      --get to_cost_group id
      -- if cost group on the move order line is not null, use it
      -- if it is null, use the from_cost_group
      IF (p_request_line_rec.to_cost_group_id IS NULL) THEN
	        IF  not (l_wms_installed) THEN							-- Added for Bug 6063903
		  l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).to_cost_group_id  := null;	-- Added for Bug 6063903
	        ELSIF (l_wms_installed) THEN							-- Added for Bug 6063903
		  l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).to_cost_group_id  := l_put_input_rec.from_cost_group_id;
	        END IF;
      ELSE
        l_wms_txn_temp_tbl(l_wms_txn_temp_tbl_size).to_cost_group_id  := p_request_line_rec.to_cost_group_id;
      END IF;
    END LOOP;

    CLOSE l_put_input_csr;
    -- insert the records into the temporary table
    -- as input to put away detailing
    insert_detail_temp_records(l_return_status, l_wms_txn_temp_tbl);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    x_return_status          := l_return_status;

    IF l_debug = 1  THEN
      log_procedure(l_api_name, 'end', 'End prepare_transfer_receipt');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF l_put_input_csr%ISOPEN THEN
        CLOSE l_put_input_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error in prepare_transfer_receipt');
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF l_put_input_csr%ISOPEN THEN
        CLOSE l_put_input_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error in prepare_transfer_receipt');
      END IF;
    --
    WHEN OTHERS THEN
      IF l_put_input_csr%ISOPEN THEN
        CLOSE l_put_input_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error in prepare_transfer_receipt');
      END IF;
  --
  END prepare_transfer_receipt;

  --
  -- debugging routine
  -- display the output records in wms_transactions_temp
  -- when called
  PROCEDURE display_temp_records IS
    CURSOR l_cur IS
      SELECT   transaction_temp_id
             , line_type_code
             , type_code
             , revision
             , lot_number
             , lot_expiration_date
             , from_subinventory_code
             , from_locator_id
             , primary_quantity
             , transaction_quantity
             , secondary_quantity
             , grade_code
             , reservation_id
             , to_subinventory_code
             , to_locator_id
             , lpn_id
          FROM wms_transactions_temp
      ORDER BY transaction_temp_id
             , line_type_code
             , type_code
             , revision
             , lot_number
             , lot_expiration_date
             , from_subinventory_code
             , from_locator_id;

    l_rec       l_cur%ROWTYPE;
    l_type      VARCHAR2(20);
    l_line_type VARCHAR2(20);
    l_api_name  VARCHAR2(30);
    l_debug     NUMBER;
  BEGIN
    /*IF inv_pp_debug.is_debug_mode = FALSE THEN
      RETURN;
    END IF; */

    IF  g_debug IS NULL  THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;

    IF l_debug = 1 THEN
       log_error(l_api_name, 'display_temp_records', 'display_temp_records');
    ELSE
       RETURN;
    END IF;


    OPEN l_cur;
    FETCH l_cur INTO l_rec;

    WHILE l_cur%FOUND LOOP
      --inv_pp_debug.send_message_to_pipe('move order line  '|| l_rec.transaction_temp_id);

      IF l_rec.line_type_code = 1 THEN
        l_line_type  := 'input line ';
      ELSE
        l_line_type  := 'output line ';
      END IF;

      IF l_rec.type_code = 1 THEN
        l_type  := 'put away';
      ELSE
        l_type  := 'pick';
      END IF;

     /* inv_pp_debug.send_message_to_pipe('line_type_code   '|| l_line_type);
      inv_pp_debug.send_message_to_pipe('type_code        '|| l_type);
      inv_pp_debug.send_message_to_pipe('revision         '|| l_rec.revision);
      inv_pp_debug.send_message_to_pipe('lot_number       '|| l_rec.lot_number);
      inv_pp_debug.send_message_to_pipe('expiration date  '|| l_rec.lot_expiration_date);
      inv_pp_debug.send_message_to_pipe('from subinventory'|| l_rec.from_subinventory_code);
      inv_pp_debug.send_message_to_pipe('from locator id  '|| l_rec.from_locator_id);
      inv_pp_debug.send_message_to_pipe('to subinventory  '|| l_rec.to_subinventory_code);
      inv_pp_debug.send_message_to_pipe('to locator id    '|| l_rec.to_locator_id);
      inv_pp_debug.send_message_to_pipe('primary quantity '|| l_rec.primary_quantity);
      inv_pp_debug.send_message_to_pipe('transaction qty  '|| l_rec.transaction_quantity);
      inv_pp_debug.send_message_to_pipe('reservation_id  '|| l_rec.reservation_id);
      inv_pp_debug.send_message_to_pipe('lpn_id  '|| l_rec.lpn_id);


      gmi_reservation_util.println('type_code        '|| l_type);
      gmi_reservation_util.println('revision         '|| l_rec.revision);
      gmi_reservation_util.println('lot_number       '|| l_rec.lot_number);
      gmi_reservation_util.println('expiration date  '|| l_rec.lot_expiration_date);
      gmi_reservation_util.println('from subinventory'|| l_rec.from_subinventory_code);
      gmi_reservation_util.println('from locator id  '|| l_rec.from_locator_id);
      gmi_reservation_util.println('to subinventory  '|| l_rec.to_subinventory_code);
      gmi_reservation_util.println('to locator id    '|| l_rec.to_locator_id);
      gmi_reservation_util.println('primary quantity '|| l_rec.primary_quantity);
      gmi_reservation_util.println('secondary quantity '|| l_rec.secondary_quantity);
      gmi_reservation_util.println('transaction qty  '|| l_rec.transaction_quantity);
      gmi_reservation_util.println('grade code       '|| l_rec.grade_code);
      gmi_reservation_util.println('reservation_id  '|| l_rec.reservation_id);
      gmi_reservation_util.println('lpn_id  '|| l_rec.lpn_id); */


      log_statement(l_api_name,'type_code ', 		l_type);
      log_statement(l_api_name,'revision ',  		l_rec.revision);
      log_statement(l_api_name,'lot_number ', 		l_rec.lot_number);
      log_statement(l_api_name,'expiration date ',	l_rec.lot_expiration_date );
      log_statement(l_api_name,'from subinventory ', 	l_rec.from_subinventory_code);
      log_statement(l_api_name,'from locator id  ', 	l_rec.from_locator_id);
      log_statement(l_api_name,'To subinventory ', 	l_rec.to_subinventory_code);
      log_statement(l_api_name,'To locator id  ', 	l_rec.to_locator_id);
      log_statement(l_api_name,'primary quantity ', 	l_rec.primary_quantity);
      log_statement(l_api_name,'secondary quantity  ', 	l_rec.secondary_quantity);
      log_statement(l_api_name,'transaction qty  ', 	l_rec.transaction_quantity);
      log_statement(l_api_name,'grade code ', 		l_rec.grade_code);
      log_statement(l_api_name,'reservation_id ', 	l_rec.reservation_id);
      log_statement(l_api_name,'lpn_id ', 		l_rec.lpn_id);

      FETCH l_cur INTO l_rec;
    END LOOP;

    CLOSE l_cur;

  END display_temp_records;

  --
  -- create output suggestion records for issue or receipt but not transfer
  -- read from the table wms_transactions_temp by the order of
  -- revision, from_sub, to_sub, from_loc, to_loc, lot_number, serial_number
  PROCEDURE output_issue_or_receipt(
    x_return_status    OUT NOCOPY    VARCHAR2
  , p_request_line_rec IN            inv_detail_util_pvt.g_request_line_rec_type
  , p_request_context  IN            inv_detail_util_pvt.g_request_context_rec_type
  , p_plan_tasks       IN            BOOLEAN ---DEFAULT FALSE
  ) IS
    l_transaction_temp_id NUMBER;

       -- Cursor for receipts or issues
    --changed by jcearley on 12/8/99
    --added order by clause so suggestions are entered into
    --mmtt in order in which the engine found them
    CURSOR l_pp_temp_csr IS
      SELECT   x.revision
             , x.from_subinventory_code
             , x.from_locator_id
             , x.to_subinventory_code
             , x.to_locator_id
             , x.lot_number
             , MAX(x.lot_expiration_date) lot_expiration_date
             , x.serial_number serial_number_start
             , x.serial_number serial_number_end
             , SUM(x.transaction_quantity) transaction_quantity
             , SUM(x.primary_quantity) primary_quantity
             , SUM(x.secondary_quantity) secondary_quantity
             , grade_code
             , MIN(x.pick_rule_id) pick_rule_id
             , MIN(x.put_away_rule_id) put_away_rule_id
             , x.reservation_id reservation_id
             , x.from_cost_group_id
             , x.to_cost_group_id
             , x.lpn_id
          FROM (SELECT wtt.revision
                     , wtt.from_subinventory_code
                     , wtt.from_locator_id
                     , wtt.to_subinventory_code
                     , wtt.to_locator_id
                     , wtt.lot_number
                     , wtt.lot_expiration_date
                     , wtt.serial_number
                     , wtt.transaction_quantity
                     , wtt.primary_quantity
                     , wtt.secondary_quantity
                     , wtt.grade_code
                     , DECODE(wtt.type_code, 2, wtt.rule_id, NULL) pick_rule_id
                     , DECODE(wtt.type_code, 1, wtt.rule_id, NULL) put_away_rule_id
                     , DECODE(wtt.type_code, 2, wtt.reservation_id, NULL) reservation_id
                     , wtt.pp_transaction_temp_id
                     , wtt.from_cost_group_id
                     , wtt.to_cost_group_id
                     , wtt.lpn_id
                  FROM wms_transactions_temp wtt
                 WHERE wtt.transaction_temp_id = l_transaction_temp_id
                   AND wtt.line_type_code = 2 -- output line
                                             ) x
      GROUP BY x.revision
             , x.from_subinventory_code
             , x.to_subinventory_code
             , x.from_locator_id
             , x.to_locator_id
             , x.from_cost_group_id
             , x.to_cost_group_id
             , x.lot_number
             , x.serial_number
             , x.reservation_id
             , x.lpn_id
             , x.grade_code
      ORDER BY MIN(x.pp_transaction_temp_id);

    --
    l_api_name   CONSTANT VARCHAR2(30)                                  := 'output_issue_or_receipt';
    l_return_status       VARCHAR2(1)                                   := fnd_api.g_ret_sts_success;
    l_curr_rec            inv_detail_util_pvt.g_output_process_rec_type;
    l_debug               NUMBER;
  --
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start output_issue_or_receipt');
    END IF;

    --
    -- Initialisize API return status to access
    x_return_status        := fnd_api.g_ret_sts_success;
    l_transaction_temp_id  := p_request_line_rec.line_id;
    -- fetch the input request line into a record
    OPEN l_pp_temp_csr;

    LOOP
      FETCH l_pp_temp_csr INTO l_curr_rec;

      IF l_pp_temp_csr%NOTFOUND THEN
        EXIT;
      END IF;
      If l_debug = 1 THEN
         log_event(l_api_name, 'add output',  'add output');
      END IF;
      inv_detail_util_pvt.add_output(l_curr_rec);
    END LOOP;

    CLOSE l_pp_temp_csr;
    IF l_debug = 1 THEN
       log_event(l_api_name, 'process output',  'process output');
    END IF;
    inv_detail_util_pvt.process_output(l_return_status
                                   , p_request_line_rec
                                   , p_request_context
                                   , p_plan_tasks);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    x_return_status        := l_return_status;

    IF l_debug = 1  THEN
       log_procedure(l_api_name, 'end', 'End output_issue_or_receipt');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF l_pp_temp_csr%ISOPEN THEN
        CLOSE l_pp_temp_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      IF l_debug = 1  THEN
         log_error(l_api_name, 'error', 'Error in output_issue_or_receipt');
      END IF;

    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF l_pp_temp_csr%ISOPEN THEN
        CLOSE l_pp_temp_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error in output_issue_or_receipt');
      END IF;
    --
    WHEN OTHERS THEN
      IF l_pp_temp_csr%ISOPEN THEN
        CLOSE l_pp_temp_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error in output_issue_or_receipt');
      END IF;
  --
  END output_issue_or_receipt;

  --
  -- create output suggestion records for transfer
  PROCEDURE combine_transfer(
    x_return_status    OUT NOCOPY    VARCHAR2
  , p_request_line_rec IN            inv_detail_util_pvt.g_request_line_rec_type
  , p_request_context  IN            inv_detail_util_pvt.g_request_context_rec_type
  , p_plan_tasks       IN            BOOLEAN ----DEFAULT FALSE
  ) IS
    l_api_name            VARCHAR2(30)                                  := 'combine_transfer';
    l_return_status       VARCHAR2(1)                                   := fnd_api.g_ret_sts_success;
    l_transaction_temp_id NUMBER;

    --changed by jcearley on 12/8/99 to order transfer order in mmtt
    -- in the order in which suggestions were created
    CURSOR l_issue_csr IS
      SELECT   revision
             , from_subinventory_code
             , from_locator_id
             , from_cost_group_id
             , to_subinventory_code
             , to_locator_id
             , to_cost_group_id
             , lot_number
             , MAX(lot_expiration_date) lot_expiration_date
             , serial_number
             , SUM(transaction_quantity) transaction_quantity
             , SUM(primary_quantity) primary_quantity
             , SUM(secondary_quantity) secondary_quantity
             , grade_code
             , MIN(rule_id) pick_rule_id
             , reservation_id
             , lpn_id
          FROM wms_transactions_temp
         WHERE transaction_temp_id = l_transaction_temp_id
           AND line_type_code = 2 -- output line
           AND type_code = 2 -- pick
      GROUP BY serial_number
             , lot_number
             , revision
             , from_subinventory_code
             , from_locator_id
             , from_cost_group_id
             , reservation_id
             , to_subinventory_code
             , to_locator_id
             , to_cost_group_id
             , lpn_id
             , grade_code
       ORDER BY revision
              , from_subinventory_code
              , from_locator_id
              , from_cost_group_id
              , lpn_id
              , lot_number
              , serial_number
              , reservation_id
              ;
      --bug 2828119 - order by sub and locator to prevent multiple picking
      --picking tasks from the same locator
      --ordER BY MIN(pp_transaction_temp_id);

          --
    CURSOR l_receipt_csr IS
      SELECT   revision
             , from_subinventory_code
             , from_locator_id
             , from_cost_group_id
             , to_subinventory_code
             , to_locator_id
             , to_cost_group_id
             , lot_number
             , MAX(lot_expiration_date) lot_expiration_date
             , serial_number
             , SUM(transaction_quantity) transaction_quantity
             , SUM(primary_quantity) primary_quantity
             , SUM(secondary_quantity) secondary_quantity
             , grade_code
             , MIN(rule_id) put_away_rule_id
             , NULL reservation_id
             , lpn_id lpn_id
          FROM wms_transactions_temp
         WHERE transaction_temp_id = l_transaction_temp_id
           AND line_type_code = 2 -- output line
           AND type_code = 1 -- put away
      GROUP BY serial_number
             , lot_number
             , revision
             , from_subinventory_code
             , from_locator_id
             , from_cost_group_id
             , to_subinventory_code
             , to_locator_id
             , to_cost_group_id
             , lpn_id
             , grade_code
       ORDER BY revision
              , from_subinventory_code
              , from_locator_id
              , from_cost_group_id
              , lpn_id
              , lot_number
              , serial_number
              , reservation_id
              ;
      --bug 2828119 - order by sub and locator to prevent multiple picking
      --picking tasks from the same locator
      --ordER BY MIN(pp_transaction_temp_id);
          --
    l_curr_issue_rec      g_combine_rec_type;
    l_curr_receipt_rec    g_combine_rec_type;
    l_issue_tbl           g_combine_tbl_type;
    l_receipt_tbl         g_combine_tbl_type;
    l_issue_tbl_size      INTEGER;
    l_receipt_tbl_size    INTEGER;
    l_curr_issue_idx      INTEGER;
    l_curr_receipt_idx    INTEGER;
    l_output_process_rec  inv_detail_util_pvt.g_output_process_rec_type;
    l_xfer_qty            NUMBER;
    l_txn_xfer_qty        NUMBER;
    l_sec_xfer_qty        NUMBER;
    l_grade_code          VARCHAR2(150);
    l_debug               NUMBER;
  BEGIN
    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
             g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'start', 'Start combine_transfer');
    END IF;

    x_return_status        := l_return_status;
    -- fetch all issue and receipt records into memory
    l_transaction_temp_id  := p_request_line_rec.line_id;
    OPEN l_issue_csr;
    l_issue_tbl_size       := 0;

    LOOP
      FETCH l_issue_csr INTO l_curr_issue_rec;
      EXIT WHEN l_issue_csr%NOTFOUND;
      l_issue_tbl_size               := l_issue_tbl_size + 1;
      l_issue_tbl(l_issue_tbl_size)  := l_curr_issue_rec;
      --inv_pp_debug.send_message_to_pipe('issue sub '|| l_curr_issue_rec.from_subinventory_code);
    END LOOP;

    CLOSE l_issue_csr;
    l_receipt_tbl_size     := 0;
    OPEN l_receipt_csr;

    LOOP
      FETCH l_receipt_csr INTO l_curr_receipt_rec;
      EXIT WHEN l_receipt_csr%NOTFOUND;
      l_receipt_tbl_size                 := l_receipt_tbl_size + 1;
      l_receipt_tbl(l_receipt_tbl_size)  := l_curr_receipt_rec;
      --inv_pp_debug.send_message_to_pipe('receipt sub '|| l_curr_receipt_rec.to_subinventory_code);
    END LOOP;

    CLOSE l_receipt_csr;
    --inv_pp_debug.send_message_to_pipe('receipt table size '|| l_receipt_tbl_size);
    --inv_pp_debug.send_message_to_pipe('issue   table size '|| l_issue_tbl_size);
    --
    -- combine the issue and receipt records into a transfer record
    -- initialize the variables
    l_xfer_qty             := 0;
    l_txn_xfer_qty         := 0;

    -- get the first issue suggestion
    IF l_issue_tbl_size < 1 THEN
      -- no issue could be recommended by the system -> exit
      RETURN;
    END IF;

    l_curr_issue_idx       := 1;

    --
    -- get the first receipt suggestion
    IF l_receipt_tbl_size < 1 THEN
      -- no receipt could be recommended by the system -> exit
      RETURN;
    END IF;

    l_curr_receipt_idx     := 1;

    --
    WHILE  l_curr_issue_idx <= l_issue_tbl_size
       AND l_curr_receipt_idx <= l_receipt_tbl_size LOOP
      -- If the current issue record and receipt record
      -- do not have the same revision, and lot number,
      -- the engine has not found a put away suggestion for the given
      -- issue suggestion.
      -- Then we will try the next issue record
      IF NOT (l_issue_tbl(l_curr_issue_idx).revision = l_receipt_tbl(l_curr_receipt_idx).revision
              OR l_issue_tbl(l_curr_issue_idx).revision IS NULL
                 AND l_receipt_tbl(l_curr_receipt_idx).revision IS NULL
             )
         OR NOT (l_issue_tbl(l_curr_issue_idx).lot_number = l_receipt_tbl(l_curr_receipt_idx).lot_number
                 OR l_issue_tbl(l_curr_issue_idx).lot_number IS NULL
                    AND l_receipt_tbl(l_curr_receipt_idx).lot_number IS NULL
                )
         OR NOT (l_issue_tbl(l_curr_issue_idx).from_subinventory_code = l_receipt_tbl(l_curr_receipt_idx).from_subinventory_code)
         OR NOT (l_issue_tbl(l_curr_issue_idx).from_locator_id = l_receipt_tbl(l_curr_receipt_idx).from_locator_id)
         OR NOT (l_issue_tbl(l_curr_issue_idx).from_cost_group_id = l_receipt_tbl(l_curr_receipt_idx).from_cost_group_id)
         OR NOT (l_issue_tbl(l_curr_issue_idx).lpn_id = l_receipt_tbl(l_curr_receipt_idx).lpn_id)
      THEN  -- the follwing is commented out because
            -- we do not copy the serial number from the picking output
            -- to put away input in prepare_transfer_receipt procedure
            -- for efficiency reason. so the output from put away
            -- suggestion does not have serial number at all. orignially
            -- it does.
            --
            --  OR NOT (l_issue_tbl(l_curr_issue_idx).serial_number
            --          = l_receipt_tbl(l_curr_receipt_idx).serial_number
            --          OR l_issue_tbl(l_curr_issue_idx).serial_number IS NULL
            --          AND l_receipt_tbl(l_curr_receipt_idx).serial_number IS NULL
            -- )

       IF l_debug = 1 THEN
           log_event(l_api_name, 'combine_failed', 'Unable to match ' || 'issue record with receipt record.  Trying next ' || 'issue record');
        END IF;
       l_curr_issue_idx  := l_curr_issue_idx + 1;
        -- pardon for the 'goto' but we haven't been able to solve it
        -- another way
        GOTO CONTINUE;
      END IF;

      --
      -- compute the actual transfer qty ( minimum of issue and receipt )
      IF l_issue_tbl(l_curr_issue_idx).primary_quantity > l_receipt_tbl(l_curr_receipt_idx).primary_quantity THEN
        l_xfer_qty                                          := l_receipt_tbl(l_curr_receipt_idx).primary_quantity;
        l_sec_xfer_qty                                      := l_receipt_tbl(l_curr_receipt_idx).secondary_quantity;
        l_issue_tbl(l_curr_issue_idx).primary_quantity      := l_issue_tbl(l_curr_issue_idx).primary_quantity - l_xfer_qty;
        l_issue_tbl(l_curr_issue_idx).secondary_quantity    := l_issue_tbl(l_curr_issue_idx).secondary_quantity - l_sec_xfer_qty;
        l_receipt_tbl(l_curr_receipt_idx).primary_quantity  := 0;
        l_receipt_tbl(l_curr_receipt_idx).secondary_quantity := 0;
      ELSE
        l_xfer_qty                                          := l_issue_tbl(l_curr_issue_idx).primary_quantity;
        l_sec_xfer_qty                                      := l_issue_tbl(l_curr_issue_idx).secondary_quantity;
        l_receipt_tbl(l_curr_receipt_idx).primary_quantity  := l_receipt_tbl(l_curr_receipt_idx).primary_quantity - l_xfer_qty;
        l_receipt_tbl(l_curr_receipt_idx).secondary_quantity := l_receipt_tbl(l_curr_receipt_idx).secondary_quantity - l_sec_xfer_qty;
        l_issue_tbl(l_curr_issue_idx).primary_quantity      := 0;
        l_issue_tbl(l_curr_issue_idx).secondary_quantity    := 0;
      END IF;

        -- Added the following code to remove the dependencies between WMSVPPEB.pls and INVVDEUB.pls for 1159

       IF l_issue_tbl(l_curr_issue_idx).transaction_quantity > l_receipt_tbl(l_curr_receipt_idx).transaction_quantity THEN
          l_txn_xfer_qty                                          := l_receipt_tbl(l_curr_receipt_idx).transaction_quantity;
          l_issue_tbl(l_curr_issue_idx).transaction_quantity      := l_issue_tbl(l_curr_issue_idx).transaction_quantity - l_txn_xfer_qty;
          l_receipt_tbl(l_curr_receipt_idx).transaction_quantity  := 0;
       ELSE
          l_txn_xfer_qty                                          := l_issue_tbl(l_curr_issue_idx).transaction_quantity;
          l_receipt_tbl(l_curr_receipt_idx).transaction_quantity  := l_receipt_tbl(l_curr_receipt_idx).transaction_quantity - l_txn_xfer_qty;
          l_issue_tbl(l_curr_issue_idx).transaction_quantity      := 0;
       END IF;

      l_output_process_rec.revision                := l_issue_tbl(l_curr_issue_idx).revision;
      l_output_process_rec.from_subinventory_code  := l_issue_tbl(l_curr_issue_idx).from_subinventory_code;
      l_output_process_rec.from_locator_id         := l_issue_tbl(l_curr_issue_idx).from_locator_id;
      l_output_process_rec.from_cost_group_id      := l_issue_tbl(l_curr_issue_idx).from_cost_group_id;
      l_output_process_rec.to_subinventory_code    := l_receipt_tbl(l_curr_receipt_idx).to_subinventory_code;
      l_output_process_rec.to_locator_id           := l_receipt_tbl(l_curr_receipt_idx).to_locator_id;
      l_output_process_rec.to_cost_group_id        := l_receipt_tbl(l_curr_receipt_idx).to_cost_group_id;
      l_output_process_rec.lot_number              := l_issue_tbl(l_curr_issue_idx).lot_number;
      l_output_process_rec.lot_expiration_date     := l_issue_tbl(l_curr_issue_idx).lot_expiration_date;
      l_output_process_rec.serial_number_start     := l_issue_tbl(l_curr_issue_idx).serial_number;
      l_output_process_rec.serial_number_end       := l_issue_tbl(l_curr_issue_idx).serial_number;
      l_output_process_rec.primary_quantity        := l_xfer_qty;
      l_output_process_rec.transaction_quantity    := l_txn_xfer_qty;
      l_output_process_rec.secondary_quantity      := l_sec_xfer_qty;
      l_output_process_rec.grade_code              := l_issue_tbl(l_curr_issue_idx).grade_code;
      l_output_process_rec.pick_rule_id            := l_issue_tbl(l_curr_issue_idx).rule_id;
      l_output_process_rec.put_away_rule_id        := l_receipt_tbl(l_curr_receipt_idx).rule_id;
      l_output_process_rec.reservation_id          := l_issue_tbl(l_curr_issue_idx).reservation_id;
      l_output_process_rec.lpn_id                  := l_issue_tbl(l_curr_issue_idx).lpn_id;
      inv_detail_util_pvt.add_output(l_output_process_rec);

      --
      -- get next issue suggestion if suggested issue qty is used up
      IF l_issue_tbl(l_curr_issue_idx).primary_quantity = 0 THEN
        l_curr_issue_idx  := l_curr_issue_idx + 1;
      END IF;

      -- get next receipt suggestion if suggested receipt qty is used up
      IF l_receipt_tbl(l_curr_receipt_idx).primary_quantity = 0 THEN
        l_curr_receipt_idx  := l_curr_receipt_idx + 1;
      END IF;

      <<continue>>
      NULL;
    END LOOP;

    inv_detail_util_pvt.process_output(l_return_status
                                      , p_request_line_rec
                                      , p_request_context
                                      , p_plan_tasks);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    x_return_status        := l_return_status;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end', 'End combine_transfer');
    END IF;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      IF l_issue_csr%ISOPEN THEN
        CLOSE l_issue_csr;
      END IF;

      IF l_receipt_csr%ISOPEN THEN
        CLOSE l_receipt_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error in combine_transfer');
      END IF;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      IF l_issue_csr%ISOPEN THEN
        CLOSE l_issue_csr;
      END IF;

      IF l_receipt_csr%ISOPEN THEN
        CLOSE l_receipt_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'unexp_error', 'Unexpected error in combine_transfer');
      END IF;
    --
    WHEN OTHERS THEN
      IF l_issue_csr%ISOPEN THEN
        CLOSE l_issue_csr;
      END IF;

      IF l_receipt_csr%ISOPEN THEN
        CLOSE l_receipt_csr;
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error in combine_transfer');
      END IF;
  --
  END combine_transfer;

  -- API name  : Create_Suggestions
  -- Type      : Private
  -- Function  : Creates pick and/or put away suggestions
  --             The program will use WMS pick/put rules/strategies
  --             if Oracle WMS is installed; otherwise, rules in
  --             mtl_picking_rules will be used.
  --
  -- Notes
  --   1. Integration with reservations
  --      If table p_reservations passed by the calling is not empty, the
  --      engine will detailing based on a combination of the info in the
  --      move order line (the record that represents detailing request),
  --      and the info in p_reservations. For example, a sales order line
  --      can have two reservations, one for revision A in quantity of 10,
  --      and one for revision B in quantity of 5, and the line quantity
  --      can be 15; so when the pick release api calls the engine
  --      p_reservations will have two records of the reservations. So
  --      if the move order line based on the sales order line does not
  --      specify a revision, the engine will merge the information from
  --      move order line and p_reservations to create the input for
  --      detailing as two records, one for revision A, and one for revision
  --      B. Please see documentation for the pick release API for more
  --      details.
  --
  --  2.  Serial Number Detailing in Picking
  --      Currently the serial number detailing is quite simple. If the caller
  --      gives a range (start, and end) serial numbers in the move order line
  --      and pass p_suggest_serial as fnd_api.true, the engine will filter
  --      the locations found from a rule, and suggest unused serial numbers
  --      in the locator. If p_suggest_serial is passed as fnd_api.g_false
  --      (default), the engine will not give serial numbers in the output.
  --
  -- Input Parameters
  --   p_api_version_number   standard input parameter
  --   p_init_msg_lst         standard input parameter
  --   p_commit               standard input parameter
  --   p_validation_level     standard input parameter
  --   p_transaction_temp_id  equals to the move order line id
  --                          for the detailing request
  --   p_reservations         reservations for the demand source
  --                          as the transaction source
  --                          in the move order line.
  --   p_suggest_serial       whether or not the engine should suggest
  --                          serial numbers in the detailing
  --
  -- Output Parameters
  --   x_return_status        standard output parameters
  --   x_msg_count            standard output parameters
  --   x_msg_data             standard output parameters
  --   l_allow_non_partial_rules Set the value to false if
  --                             l_remaining_quantity returned  by compute_pick_detail
  --                             is greater than 0

  -- Version     :  Current version 1.0
  --

  PROCEDURE create_suggestions(
    p_api_version         IN            NUMBER
  , p_init_msg_list       IN            VARCHAR2
  , p_commit              IN            VARCHAR2
  , p_validation_level    IN            NUMBER
  , x_return_status       OUT NOCOPY    VARCHAR2
  , x_msg_count           OUT NOCOPY    NUMBER
  , x_msg_data            OUT NOCOPY    VARCHAR2
  , p_transaction_temp_id IN            NUMBER
  , p_reservations        IN            inv_reservation_global.mtl_reservation_tbl_type
  , p_suggest_serial      IN            VARCHAR2
  , p_simulation_mode     IN            NUMBER
  , p_simulation_id       IN            NUMBER
  , p_plan_tasks          IN            BOOLEAN
  , p_quick_pick_flag     IN   		VARCHAR2
  , p_wave_simulation_mode IN VARCHAR2 DEFAULT 'N'
  ) IS
    l_api_version       CONSTANT NUMBER                                         := 1.0;
    l_api_name          CONSTANT VARCHAR2(30)                                   := 'Create_Suggestions';
    l_strategy_id                NUMBER;
    l_rule_id                    NUMBER;  -- [l_rule_id  New Column Added for K ]
    l_return_status              VARCHAR2(1)                                    := fnd_api.g_ret_sts_success;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_counter                    PLS_INTEGER; --8809951 changed to Pls_Integer
    l_type_code                  PLS_INTEGER; --8809951 changed to Pls_Integer
    l_number                     NUMBER;
    l_request_context            inv_detail_util_pvt.g_request_context_rec_type;
    l_request_line_rec           inv_detail_util_pvt.g_request_line_rec_type;
    l_move_order_type            PLS_INTEGER; --8809951 changed to Pls_Integer
    l_loc_control_from           PLS_INTEGER; --8809951 changed to Pls_Integer
    l_loc_control_to             PLS_INTEGER; --8809951 changed to Pls_Integer
    l_item_control_from          PLS_INTEGER; --8809951 changed to Pls_Integer
    l_item_control_to            PLS_INTEGER; --8809951 changed to Pls_Integer
    l_simulation_mode            PLS_INTEGER; --8809951 changed to Pls_Integer
    l_revert_capacity            BOOLEAN;
    l_project_id                 NUMBER;
    l_task_id                    NUMBER;
    l_allow_cross_proj_issues    VARCHAR2(1);
    l_allow_cross_unitnum_issues VARCHAR2(1);
    l_unit_number                VARCHAR2(30);
    l_allow_non_partial_rules    BOOLEAN; --- DEFAULT TRUE;
    l_return_type                VARCHAR2(1);
    l_return_type_id             NUMBER;
    l_sequence_number            NUMBER;
    l_rules_engine_mode          NUMBER :=  1;  --:= NVL(fnd_profile.VALUE('WMS_RULES_ENGINE_MODE'), 0);
    l_wip_rsv_exists             PLS_INTEGER; --8809951 changed to Pls_Integer

    --- Rules J Project Variables
    ---
    l_lpn_context                PLS_INTEGER := 0;  --8809951 changed to Pls_Integer
    l_current_release_level      NUMBER      :=  WMS_UI_TASKS_APIS.G_WMS_PATCH_LEVEL;
    l_j_release_level            NUMBER      :=  WMS_UI_TASKS_APIS.G_PATCHSET_J;
    l_quick_pick_flag            VARCHAR2(1);  	-- 'J Project:This variable is used for QuickPick during Inventory Move
                                               	--  Values 'Y' - Perform Quick Pick ,
                                               	--         'N' - Do not call quick Pick
                                               	--         'Q' - Perform Quick pick for Version 11.5.9 without qtr_tee creation
    --- Switching to New Strategy Search method
      --8809951 changed to Pls_Integer
     l_org_loc_control          PLS_INTEGER;   	-- Bug#3051649
     l_debug                    PLS_INTEGER;   	-- 1 for debug is on , 0 for debug is off
     l_progress                 VARCHAR2(10);  	-- local variable to track program progress,
                                               	-- especially useful when exception occurs

    -- Added to skip rules processing if pick release process and locator provided bug3237702
     l_locator_id               NUMBER;
     is_pickrelease             BOOLEAN;


     l_allow_nr_sub_xfer  VARCHAR2(1) := 'N' ;  -- Bug #4006426

    -- LG convergence add
     l_pp_transaction_temp_id   NUMBER;
    -- end LG convergence add
     l_wms_installed BOOLEAN := TRUE; --added for bug 8292754
     x_api_return_status VARCHAR2(2); --added for bug 8292754
     l_return_val     BOOLEAN;  --added for bug 9210454

    ---
    --the following cursors get information used in wms_rule_pvt.apply to
    --compare src sub/loc and dest sub/loc.  The information is queried here
    --and stored in global variables to prevent multiple queries for the
    --same info (which would happen if we queried for data in apply)

    CURSOR c_move_order_type IS
      SELECT move_order_type
        FROM mtl_txn_request_headers
       WHERE header_id = l_request_line_rec.header_id;

    CURSOR c_sub_loc_control_from IS
      SELECT locator_type
        FROM mtl_secondary_inventories
       WHERE secondary_inventory_name = l_request_line_rec.from_subinventory_code
         AND organization_id = l_request_line_rec.organization_id;

    CURSOR c_sub_loc_control_to IS
      SELECT locator_type
        FROM mtl_secondary_inventories
       WHERE secondary_inventory_name = l_request_line_rec.to_subinventory_code
         AND organization_id = l_request_line_rec.to_organization_id;

    CURSOR c_item_loc_control_from IS
      SELECT location_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = l_request_line_rec.inventory_item_id
         AND organization_id = l_request_line_rec.organization_id;

    CURSOR c_item_loc_control_to IS
      SELECT location_control_code
        FROM mtl_system_items
       WHERE inventory_item_id = l_request_line_rec.inventory_item_id
         AND organization_id = l_request_line_rec.to_organization_id;

    CURSOR c_rule_type_code IS
      SELECT type_code
        FROM wms_rules_b
       WHERE rule_id = p_simulation_id;

    CURSOR c_strategy_type_code IS
      SELECT type_code
        FROM wms_strategies_b
       WHERE strategy_id = p_simulation_id;

    CURSOR c_project_param IS
      SELECT allow_cross_proj_issues
           , allow_cross_unitnum_issues
        FROM pjm_org_parameters
       WHERE organization_id = l_request_line_rec.organization_id;

   -- 8809951 Modified Cursor
    CURSOR c_wip_reservations IS
        SELECT 1
          FROM mtl_reservations
         WHERE organization_id = l_request_line_rec.organization_id
           AND supply_source_type_id = 5
           AND supply_source_header_id = l_request_line_rec.txn_source_id;


     --Bug #3051649 /Grao : Org locator control
    CURSOR c_org_loc_control IS
    SELECT stock_locator_control_code
      FROM mtl_parameters
     WHERE organization_id = l_request_line_rec.organization_id;

    /* Bug # 5265024
    CURSOR l_wms_txn_temp_id_csr IS
      SELECT wms_transactions_temp_s.NEXTVAL
        FROM DUAL;
    */

  BEGIN

    IF NOT(inv_cache.is_pickrelease AND g_debug IS NOT NULL) THEN
          g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;
    l_debug := g_debug;
    l_progress := 10;
    --
    If l_debug = 1  THEN
       log_procedure(l_api_name, 'start', 'Start create_suggestions');
       log_event(
                    l_api_name
                 , 'start_detail'
                 , 'Starting the WMS Rules engine ' || 'to allocate material for move order line: '
                 || p_transaction_temp_id
                 );
    End if;
    --8809951 Clean up all the rules in the cahce.
    Wms_cache.Cleanup_rules_cache;

    l_allow_nr_sub_xfer :=  Upper(NVL( SUBSTR(FND_PROFILE.VALUE('INV_ALLOW_NR_SUB_XFER'),1,1), 'N')) ; -- Bug#4006426

    If l_debug = 1  THEN
        log_event( l_api_name, 'WMS_ALLOW_NR_SUB_XFER := ',   l_allow_nr_sub_xfer );
    End if;

    /* Fix for Bug#8355668. Remove existing elements for Select Available Inventory form */
    if (p_simulation_mode = 10 ) then
       WMS_SEARCH_ORDER_GLOBALS_PVT.g_available_inv_tbl.DELETE  ;
    end if ;

    -- Standard start of API savepoint
    SAVEPOINT create_suggestions_sa;

    --
    -- Standard Call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- Initialize message list if p_init_msg_list is set to true
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    if p_wave_simulation_mode ='Y' then l_simulation_mode := 0; end if;
    --
    -- Initialisize API return status to access
    x_return_status          := fnd_api.g_ret_sts_success;
    --
    g_trace_header_id        := NULL;
    g_business_object_id     := NULL;
    g_sugg_failure_message   := NULL; -- Patchset 'J'

    -- log_event(l_api_name, 'Create Suggestions',  'J check');
    -- 'J Changes Initilize the local Quickpick variable
    IF (l_current_release_level >= l_j_release_level
        And p_simulation_mode <> 10     -- LG convergence add
        ) THEN

        IF l_debug = 1 THEN
           log_event(l_api_name, 'Check J release', 'Current release is above J. set l_quick_pick_flag to Y');
        END IF;
        l_quick_pick_flag := nvl(p_quick_pick_flag, 'N');
        IF ( l_quick_pick_flag = 'N'  and p_simulation_mode IS not NULL)  then
            --- get LPN Context for the given move order line
            --- if LPN_CONTEXT is 1 then set the quick_pick_flag = 'Y'
            IF l_debug = 1 THEN
              log_event(l_api_name, 'Create Suggestions',
                 'If in Simulation Mode - Get LPN Context');
            END IF;

            BEGIN
              l_progress := 100;

              SELECT lpn_context
              INTO   l_lpn_context
              FROM   wms_license_plate_numbers
              WHERE  lpn_id =  (SELECT lpn_id
                                FROM mtl_txn_request_lines mtrl
                                WHERE   mtrl.line_id = p_transaction_temp_id);
           l_progress := 110;

           IF l_lpn_context = 1 THEN
              l_quick_pick_flag := 'Y';
           End if;
             EXCEPTION
              WHEN  OTHERS THEN
               IF l_debug = 1 THEN
                  log_error(l_api_name, 'other', 'lpn_context in create_suggestions is not available ');
               END IF;
               NULL;
            END;  -- End of Begin

         END IF; -- End If l_quick_pick_flag = 'N'  and p_simulation_mode IS not NULL

    ELSE
      /* Bug # 4006426 -- Quick Pick functionality is enabled for 11.5.9 /Version 'I'
          Following code is added to check the context of the LPN and the value
          of the l_quick_pick_flag is set to 'Q'
          so that, the calling programs (WMSVPPSB.pls and WMSVPPRB.pls ) could behave differently

         New Behavior : Qty tree is not going to be  created or queried for performance reasons instead 'Availability
                        check'  will be done based on the MOQD and reservation tables. A new local  procedure
                        validate_and_insert_noqtytree()  will be created  to insert data in WTT */

        l_quick_pick_flag := 'N';

        BEGIN
          SELECT lpn_context
            INTO l_lpn_context
            FROM wms_license_plate_numbers
            WHERE lpn_id = l_request_line_rec.lpn_id ; /* (SELECT lpn_id
                              FROM mtl_txn_request_lines mtrl
                             WHERE mtrl.line_id = p_transaction_temp_id);*/

          IF l_lpn_context = 1 AND l_allow_nr_sub_xfer = 'Y' THEN
             l_quick_pick_flag := 'Q';
          ELSE
             l_quick_pick_flag := 'N';
          End if;
        EXCEPTION
        WHEN  OTHERS THEN
        IF l_debug = 1 THEN
           log_error(l_api_name, 'other', 'lpn_context in create_suggestions is not available 1159 ');
        END IF;
        NULL;
        END;  -- End of Begin

    END IF;

    -- log_event(l_api_name, 'Create Suggestions',  'after J check');
    --validation simulation mode
    -- Simulation mode should = 0 if user passes invalid value
    -- for simulation mode, or if user passes simulation mode as 1 or 2,
    -- but doesn't pass in simulation_id
    IF p_simulation_mode IS NULL
       OR (p_simulation_mode < g_full_simulation AND p_simulation_mode <> g_available_inventory)
       OR p_simulation_mode > g_put_full_mode THEN
      l_simulation_mode  := g_no_simulation;
    ELSIF  p_simulation_id IS NULL
           AND p_simulation_mode
              IN (g_pick_rule_mode, g_pick_strategy_mode
                 , g_put_rule_mode, g_put_strategy_mode)
       THEN
      l_simulation_mode  := g_no_simulation;
    ELSE
      l_simulation_mode  := p_simulation_mode;
    END IF;
    IF l_debug = 1 THEN
       log_event(l_api_name, 'Create Suggestions',  'simulation mode '||l_simulation_mode);
    END IF;

    -- Revert Capacity in any simulation mode
    IF l_simulation_mode <> g_no_simulation THEN
      l_revert_capacity  := TRUE;
    ELSE
      l_revert_capacity  := FALSE;
    END IF;

    -- validate input and initialize
    If l_debug = 1 THEN
       log_event(l_api_name, 'Create Suggestions', 'before init');
    END IF;
    inv_detail_util_pvt.validate_and_init(x_return_status
                 , p_transaction_temp_id
                 , p_suggest_serial
                 , l_request_line_rec
                 , l_request_context
		 , p_wave_simulation_mode);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    IF l_debug = 1 THEN
       log_event(l_api_name, 'Create Suggestions', 'after init');
       log_event(l_api_name, 'Create Suggestions', 'l_return_status '||l_return_status);
       log_event(l_api_name, 'Create Suggestions', 'Cross-Doc Data --------------');
       log_event(l_api_name, 'Create Suggestions', 'backorder_delivery_detail_id :'||l_request_line_rec.backorder_delivery_detail_id);
       log_event(l_api_name, 'Create Suggestions', 'to_subinventory_code :'||l_request_line_rec.to_subinventory_code);
       log_event(l_api_name, 'Create Suggestions', 'to_locator_id:'||l_request_line_rec.to_locator_id);

    END IF;

    g_mo_quantity := l_request_line_rec.primary_quantity ; -- [ Storing the mo qty for tolerance calculations ]
    g_Is_xdock := FALSE;
    IF l_request_line_rec.backorder_delivery_detail_id is not NULL and
       l_request_line_rec.to_subinventory_code is not null and
       l_request_line_rec.to_locator_id  is not null THEN
       g_Is_xdock := TRUE ;
    END IF;

    /*IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;*/
    -- Transfer flag is always false when simulating
    -- picking rules or strategies.  When simulation putaway rules or
    -- strategies for transfers, we execute the picking side of the engine
    -- normally, so there is not need to change the transfer flag
    IF l_simulation_mode IN (g_pick_strategy_mode, g_pick_rule_mode, g_pick_full_mode) THEN
      l_request_context.transfer_flag  := FALSE;
      l_request_context.type_code      := 2;
    END IF;

    --setting global variables used in wms_rule_pvt.
    If l_debug = 1 THEN
       log_event(l_api_name, 'Create Suggestions', 'before fetching move order type '||l_move_order_type);
    END IF;
    --8809951 start, Removed code to fetch from cursor and fetched it from INV.CACHE

     IF NOT inv_cache. set_mtrh_rec(l_request_line_rec.header_id) THEN
		    If l_debug = 1 THEN
			    log_event(l_api_name,'Create Suggestions','MTRH not found ');
		    End If;
		  RAISE fnd_api.g_exc_unexpected_error;
     END IF;
    l_move_order_type :=inv_cache.mtrh_rec.move_order_type;
    --8809951 end
    IF l_debug = 1 THEN
       log_event(l_api_name, 'Create Suggestions', 'after fetching move order type '||l_move_order_type);
    END IF;

    g_move_order_type        := l_move_order_type;
    g_transaction_action_id  := l_request_context.transaction_action_id;

    --the locator control variables are only checked for non-pick-wave
    -- move orders
    -- GRAO
    -- Bug# 2454149 : Same Source and Dest Subinv is allowed for both
    -- WIP Issues and Back flush type of MOve orders also.

    -- Bug 2666620: BackFlush MO Type Removed
    IF l_move_order_type IN (3, 5) THEN --pick wave, WIP type  move order
      g_dest_sub_pick_allowed  := 1;
    ELSE
     --log_event(l_api_name, 'Create Suggestions', 'else ');
      g_dest_sub_pick_allowed  := 0;
    END IF; -- bug 3972784 populate the globals regardless.

    --8809951 start Removed cursors and using INV_CACHE

        IF (inv_cache.set_fromsub_rec(l_request_line_rec.organization_id, l_request_line_rec.from_subinventory_code))
	THEN
		l_loc_control_from:=inv_cache. fromsub_rec.locator_type;
	END IF;
	IF (inv_cache.set_tosub_rec(l_request_line_rec.to_organization_id, l_request_line_rec.to_subinventory_code))
	THEN
		l_loc_control_to:=inv_cache. tosub_rec.locator_type;
	END IF;
	IF ( INV_CACHE.set_item_rec(l_request_line_rec.organization_id, l_request_line_rec.inventory_item_id) )
	THEN
		l_item_control_from:= inv_cache.item_rec.location_control_code;
	END IF;
	IF ( INV_CACHE.set_item_rec(l_request_line_rec.to_organization_id, l_request_line_rec.inventory_item_id) )
	THEN
		l_item_control_to := inv_cache.item_rec.location_control_code;
	END IF;
    IF (INV_CACHE.set_org_rec(l_request_line_rec.organization_id) ) THEN
		l_org_loc_control := inv_cache.org_rec. stock_locator_control_code;
    END If;

      g_sub_loc_control        := NVL(l_loc_control_from,  l_loc_control_to);
      g_item_loc_control       := NVL(l_item_control_from, l_item_control_to);
      g_org_loc_control        := l_org_loc_control;

      --8809951 end

   --bug 2589499 -- if reservation exists for WIP putaway, do not putaway
   -- to non-reservable sub.
   --set a global variable here, and reference it in WMS_RULE_PVT
   g_reservable_putaway_sub_only := FALSE;
   l_wip_rsv_exists := 0;

   -- log_event(l_api_name, 'Create Suggestions', 'after all the item check');
    --for putaway move orders, set posting flag to N (it is Y by default)
    IF l_move_order_type = 6 THEN -- put away move order
--      l_request_context.posting_flag  := 'N';    -- bug fix 3438349

      If l_request_context.transaction_source_type_id = 5 And
         l_request_line_rec.transaction_type_id = 44 Then

         OPEN c_wip_reservations;
         FETCH c_wip_reservations INTO l_wip_rsv_exists;
         IF c_wip_reservations%NOTFOUND THEN
           l_wip_rsv_exists := 0;
         END IF;
         CLOSE  c_wip_reservations;  -- Bug # 4997883
         IF l_wip_rsv_exists = 1 THEN
           g_reservable_putaway_sub_only := TRUE;
         END IF;
      End If;
    END IF;

    g_serial_number_control_code:=l_request_context.item_serial_control_code;
    --don't detail serial numbers for items that are serial controlled only
    -- at sales order issue
    IF l_request_context.item_serial_control_code = 6 THEN
      l_request_context.item_serial_control_code := 1;
    END IF;

    --log_event(l_api_name, 'Create Suggestions', 'before sys_task_type');
    /*  Get the wms system task type
        changed the call to add 2 new paramters p_transaction_Action_id
        and p_transaction_source_type_id for patchset H changes */
    wms_rule_pvt.get_wms_sys_task_type(
      p_move_order_type            => l_move_order_type
    , p_transaction_action_id      => l_request_context.transaction_action_id
    , p_transaction_source_type_id => l_request_context.transaction_source_type_id
    , x_wms_sys_task_type          => l_request_context.wms_task_type
    );
    --log_event(l_api_name, 'Create Suggestions', 'after sys_task_type');

    INSERT INTO wms_txn_context_temp
                (
                line_id
              , txn_source_id
              , txn_source_line_id
              , txn_source_name
              , txn_source_line_detail
              , freight_carrier_code
              , customer_id
                )
         VALUES (
                l_request_line_rec.line_id
              , l_request_context.txn_header_id
              , l_request_context.txn_line_id
              , NULL
              , l_request_context.txn_line_detail
              , l_request_context.freight_code
              , l_request_context.customer_id
                );

   -- Check whether this is a pick release process and if locator is specified bug3237702
   If inv_cache.is_pickrelease then
      is_pickrelease := true;
      l_locator_id := inv_cache.tolocator_id;
   ELSIF p_wave_simulation_mode = 'Y' THEN
	l_locator_id := inv_cache.tolocator_id;
   End if;

    -- log_event(l_api_name, 'Create Suggestions', 'after insert txn_context');
    -- the first round will deal with issues, receipts
    -- and the issue part of transfers
    -- the second round will deal with the receipt part
    -- of transfers
    l_type_code              := l_request_context.type_code;
    -- 'J Project' : Setting the quick_pick parameter to false , if it is putaway ---
    --IF (l_current_release_level >= l_j_release_level ) THEN   --- Bug # 4006426
        IF l_type_code = 1 then
           l_quick_pick_flag := 'N';
        END IF;
    --END IF; -- Bug#4006426
    FOR l_counter IN 1 .. 2 LOOP
      -- if not a transfer, or if we are simulating strategy or rule,
      -- or simulation if for available inventory LG.
      -- no need to call Search and Apply a second time.
      IF  l_counter = 2
          AND (l_request_context.transfer_flag = FALSE
                 OR l_simulation_mode = g_available_inventory
              )
      THEN
        EXIT;
      END IF;

      -- Find strategies when
      -- a. not simulating
      -- b. simulating the full pick process
      -- c. simulating the full put away process
      -- d. simulate put rule or strategy, you have to find pick strategy
      --    for transfers

      IF l_simulation_mode IN (g_full_simulation, g_no_simulation, g_available_inventory) -- LG convergence
         OR l_simulation_mode IN (g_pick_full_mode, g_put_full_mode, g_pick_rule_mode, g_put_rule_mode
                                                                             ,g_put_strategy_mode, g_pick_strategy_mode) --Bug#6015798, Bug#7182139
         OR (l_simulation_mode IN (g_put_strategy_mode, g_put_rule_mode)
             AND l_request_context.transfer_flag = TRUE
             AND l_counter = 1
            ) THEN
        IF l_counter = 1 THEN
          IF l_request_context.type_code = 2 THEN
            IF l_debug = 1 THEN
               log_event(l_api_name, 'start_pick', 'Starting pick allocation');
            END IF;
            l_strategy_id  := l_request_context.pick_strategy_id;
	    IF l_simulation_mode =  g_pick_strategy_mode THEN
                l_strategy_id  := p_simulation_id;
            END IF;
          ELSE
            IF l_debug = 1 THEN
               log_event(l_api_name, 'start_put_only', 'Starting put away allocation');
             END IF;
             l_strategy_id  := l_request_context.put_away_strategy_id;
          END IF;
        ELSE
          IF l_debug = 1 then
             log_event(l_api_name, 'start_put', 'Starting put away allocation');
          END IF;
          l_strategy_id  := l_request_context.put_away_strategy_id;
          l_type_code    := 1; -- put away for the second round
        END IF;
         --Begin bug 4749595/4769085
        IF l_type_code = 1 then
           l_quick_pick_flag := 'N';
        END IF;
        --End   bug 4749595/4769085

        IF l_debug = 1 THEN
           log_statement(l_api_name, 'strategy_search', 'modified set l_quick_pick_flag '|| l_quick_pick_flag);
           log_event(l_api_name, 'start_pick', 'getting the context ');
        END IF;

      -- clean up the input records first
      DELETE FROM wms_transactions_temp
            WHERE transaction_temp_id = p_transaction_temp_id
              AND line_type_code = 1;

      --
      IF p_simulation_mode <> 10 THEN -- LG convergenece add
        IF l_counter = 1 THEN
          -- Prepare transaction records for pp engine
          -- for transfers only the issue is considered at this time
          prepare(l_return_status
                , l_request_line_rec
                , l_request_context
                , p_reservations
                , l_allow_non_partial_rules);

          --
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
          -- Treat receipt for transfers, ie. copy the issue output data in
          -- WMS_TRANSACTIONS_TEMP as new input records for receipt part
          prepare_transfer_receipt(l_return_status
                                 , l_request_line_rec
                                 , l_request_context);
          --
          IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;
   -- LG convergence add
   -- Since we may not have a reservation when p_simulation_mode is 10 for all move order types
   -- so insert fake data into wms_transactions_temp
   IF p_simulation_mode = g_available_inventory
   THEN
     /* 5265024
      OPEN l_wms_txn_temp_id_csr;
      FETCH l_wms_txn_temp_id_csr INTO l_pp_transaction_temp_id ;
      CLOSE l_wms_txn_temp_id_csr;
     */
      log_event(l_api_name, '','insert into wtt '||l_pp_transaction_temp_id);
      INSERT INTO wms_transactions_temp
                  (
                  pp_transaction_temp_id
                , transaction_temp_id          -- mo_line_id
                , type_code                    -- mo
                , line_type_code               -- 1
                , transaction_quantity
                , primary_quantity
                , secondary_quantity
                  )
           VALUES ( wms_transactions_temp_s.NEXTVAL
              --    l_pp_transaction_temp_id
                , l_request_line_rec.line_id
                , 2
                , 1
                , l_request_line_rec.quantity
                , l_request_line_rec.quantity
                , l_request_line_rec.secondary_quantity
                  );
   END IF;
      -- end LG convergence
      --
      IF (wms_rule_pvt.isruledebugon(l_simulation_mode)
           and l_simulation_mode <> g_available_inventory) THEN
        IF l_debug = 1 THEN
             log_procedure(l_api_name, 'insert_trace_header', 'Calling insert_trace_header ');
        END IF;
        wms_search_order_globals_pvt.insert_trace_header(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_validation_level           => fnd_api.g_valid_level_full
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , x_header_id                  => g_trace_header_id
        , p_pick_header_id             => g_trace_header_id
        , p_move_order_line_id         => p_transaction_temp_id
        , p_total_qty                  => l_request_line_rec.quantity - l_request_line_rec.quantity_detailed
        , p_secondary_total_qty        => l_request_line_rec.secondary_quantity - l_request_line_rec.secondary_quantity_detailed
        , p_type_code                  => l_type_code
        , p_business_object_id         => g_business_object_id
        , p_object_id                  => l_sequence_number
        , p_strategy_id                => l_strategy_id
        );

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      -- Added to support PJM
      --  Query the columns ALLOW_CROSS_PROJ_ISSUES and ALLOW_CROSS_UNITNUM_ISSUES
      --  from the table pjm_org_Parameters where
      --  If ALLOW_CROSS_PROJ_ISSUES is Y, then set project and task to NULL
      --  for picks only.
      --  If ALLOW_CROSS_UNITNUM_ISSUES is Y, set the unit_number to NULL.
      --  BUG 2880682 : Treating null project/task as common project/task and forcing
      --                picking from common inventory when allow_cross_proj_issues is off.
      --                The same holds for unit number
      l_project_id   := l_request_line_rec.project_id;
      l_task_id      := l_request_line_rec.task_id;
      l_unit_number  := l_request_line_rec.unit_number;

      IF l_type_code = 2 THEN
       --8809951 start
       IF ( INV_CACHE.set_pjm_org_parms_rec(l_request_line_rec.organization_id)) THEN --9650219
	      l_allow_cross_proj_issues    := Nvl(inv_cache.pjm_org_parms_rec.allow_cross_proj_issues,'Y');
              l_allow_cross_unitnum_issues := Nvl(inv_cache.pjm_org_parms_rec.allow_cross_unitnum_issues,'Y');
       ELSE
         log_procedure(l_api_name, 'Error in setting pjm_org_parms_rec','Setting pjm_org_parms');
       END IF;
       --8809951 end

        --start change for bug 8292754
	--checking if org is wms  enabled .Added for bug 8292754
	 l_wms_installed :=   WMS_INSTALL.check_install(
	                                    x_return_status   => x_api_return_status,
	                                    x_msg_count       => x_msg_count,
	                                    x_msg_data        => x_msg_data,
	                                    p_organization_id => l_request_line_rec.organization_id);
       --Changed for bug 8292754
       --Allow cross project issue is not supported for sales order issue in non-wms org
        IF (l_allow_cross_proj_issues = 'Y')
	 AND ((l_request_context.transaction_source_type_id <> 2 AND l_wms_installed= FALSE )
	      OR (l_wms_installed = TRUE))
	THEN
	 log_procedure(l_api_name, 'l_allow_cross_proj_issues', 'Nulling project and Task ');
          l_project_id  := NULL;
          l_task_id     := NULL;
        ELSE
	 log_procedure(l_api_name, 'l_allow_cross_proj_issues', 'Maintaining project and Task ');
          l_project_id := nvl(l_project_id, -7777);
          l_task_id := nvl(l_task_id, -7777);
        END IF;
       --End change for bug 8292754


        IF l_allow_cross_unitnum_issues = 'Y' THEN
          l_unit_number  := NULL;
        ELSE
          l_unit_number := nvl(l_unit_number, '-7777');
        END IF;

	 --start change for bug 9210454
        BEGIN
         l_return_val := inv_cache.set_item_rec(l_request_line_rec.organization_id, l_request_line_rec.inventory_item_id);
	 log_procedure(l_api_name, 'Setting inv_cache', 'for soft pegg item');
	 EXCEPTION
	 WHEN OTHERS THEN
	    NULL;
        END;

	IF ( inv_cache.item_rec.end_assembly_pegging_flag IN ('A','Y','B')) THEN
         log_procedure(l_api_name, 'Soft Pegged Item in INV org', 'Nulling project and Task for soft pegged item ');
          l_project_id  := NULL;
          l_task_id     := NULL;
        END IF;

        --end change for bug 9210454

    END IF;
      ------------------------
      -- [[

      --Added bug3237702
      -- search for a strategy if not given in the input parameter
      -- If pick_release and locator supplied and doing Putaway side of transaction
      -- then no need to use rule

      -- [ Setting g_use_rule flag = 'Y' for follwing cases ]
      -- Case 1. If pick release and putaway loop and locator is not null  - Pick release
      -- Case 2. If Detailed reservations exsist for the total requested qty and the item is serial  - handled in prepare()
      -- Case 3. For Cross-docking putaway

      -- [Case 1
      --IF  (is_pickrelease AND l_type_code = 1 AND l_locator_id IS NOT NULL ) THEN
      IF  ((is_pickrelease OR p_wave_simulation_mode = 'Y') AND l_type_code = 1 AND l_locator_id IS NOT NULL ) THEN
            g_use_rule := 'N' ;
      END IF;
      -- [Case 3
      If  (g_Is_xdock and l_type_code = 1)   THEN
           g_use_rule := 'N' ;
      END IF;
      -----
      IF l_debug = 1 THEN
      	 log_event(l_api_name, 'Setting g_use_rule', g_use_rule);
      	 --IF  (is_pickrelease AND l_type_code = 1 AND l_locator_id IS NOT NULL ) THEN
	 IF  ((is_pickrelease OR p_wave_simulation_mode = 'Y') AND l_type_code = 1 AND l_locator_id IS NOT NULL ) THEN
      	      log_statement(l_api_name, 'Case 2:' , 'Pick release + Putaway loop + Dest. Locator is not null');
      	 ELSIF (g_Is_xdock and l_type_code = 1) THEN
      	      log_statement(l_api_name, 'Case 3:' , 'Cross-dock + Putaway + Dest. Locator is not null');
      	 ELSE
      	      log_statement(l_api_name, 'Case 1:' , 'Serial detailed resv +  Picking');
         END IF;
      END IF;
      -----
      If (l_strategy_id IS NULL) /* AND NOT (is_pickrelease AND l_type_code = 1 AND l_locator_id IS NOT NULL)*/ THEN
       --IF l_strategy_id IS NULL THEN Bug 3237702 ends
	  IF l_debug = 1 THEN
	     log_event(l_api_name, 'strategy_search', 'Strategy not defined on move order line.  Calling '
	                          || 'the strategy search procedure');
	     log_statement(l_api_name, 'strategy_search', 'l_quick_pick_flag '|| l_quick_pick_flag );
	     log_statement(l_api_name, 'strategy_search', 'g_use_rule '|| g_use_rule);
	  END IF;
	  -- [ Added the condition of - g_use_rule = 'Y'  ]
	  IF nvl(l_quick_pick_flag, 'N')  = 'N' AND ( g_use_rule = 'Y' ) THEN
	     IF l_debug = 1 THEN
		log_event(l_api_name, 'Calling Strategy Search', 'wms_rules_workbench_pvt.search()');
		log_statement(l_api_name, 'p_transaction_temp_id =>' ,p_transaction_temp_id);
	     END IF;
            l_return_type := 0;
            l_return_type_id := 0;
            l_rule_id  := NULL;  --- Bug#    5178290 / 5233300
	   wms_rules_workbench_pvt.search(
	     p_api_version                => 1.0
	   , p_init_msg_list              => fnd_api.g_false
	   , p_validation_level           => fnd_api.g_valid_level_none
	   , x_return_status              => l_return_status
	   , x_msg_count                  => l_msg_count
	   , x_msg_data                   => l_msg_data
	   , p_transaction_temp_id        => p_transaction_temp_id
	   , p_type_code                  => l_type_code
	   , x_return_type                => l_return_type
	   , x_return_type_id             => l_return_type_id
	   , p_organization_id            => l_request_line_rec.organization_id
	   , x_sequence_number            => l_sequence_number
	   );

	    IF l_debug = 1 THEN
	       log_event(l_api_name, 'End Search', 'Values returned ..');
	       log_statement(l_api_name, 'l_return_status =>' 	,l_return_status);
	       log_statement(l_api_name, 'p_organization_id =>' ,l_request_line_rec.organization_id);
	       log_statement(l_api_name, 'l_type_code =>' 	,l_type_code);
	       log_statement(l_api_name, 'l_sequence_number =>' ,l_sequence_number);
	       log_statement(l_api_name, 'l_return_type =>' 	,l_return_type);
	       log_statement(l_api_name, 'l_return_type_id =>' 	,l_return_type_id);
	    END IF;

	    -- If no strategy is assigned, still detail, but
	    -- with no strategy or rules

	   IF l_return_status <> fnd_api.g_ret_sts_success THEN

	      IF l_debug = 1 THEN
		 log_event(
		   l_api_name
		   , 'no_strategy_found'
		   ,  'The strategy search function did not find an ' || 'eligible strategy for this move order.'
		   );
	       END IF;

	      l_strategy_id  := NULL;
	   ELSE      -- for assigning strategy Id based on the Return type , if it is 'S'

	     IF l_return_type = 'S' THEN
	        l_strategy_id  := l_return_type_id;
                l_rule_id := NULL;
	     -- [ Based on the rule assignments , rule work bench returns the rule_id ]
	     ELSIF l_return_type = 'R' THEN
		   l_rule_id :=  l_return_type_id;
		  l_strategy_id  := NULL;
	     END IF;
	     IF l_debug = 1 THEN
	        log_statement(l_api_name, 'wms_rules_workbench_pvt.search()', 'l_strategy_id  '|| l_strategy_id );
	     ELSE
	        log_statement(l_api_name, 'wms_rules_workbench_pvt.search()', 'l_rule_id  '|| l_rule_id );
	     END IF;

	  END IF; -- FND_API.G_RET_STS_SUCCESS

	 END IF; -- J PROJECT : if not quickpick
       END IF; --STRATEGY ID / Rule ID is NULL

     ELSIF l_simulation_mode IN (g_pick_strategy_mode, g_put_strategy_mode) THEN
       l_strategy_id  := p_simulation_id;
     ELSE
       l_strategy_id  := NULL;
     END IF;
     -- [ setting the flag g_use_rule for putaway
     -- all the code to use/notuse  rules search will be streamlined
     -- Logic : if the search API is not called , then set the rule id  to -999
     -- so that it could be handled in the strategy program as a special program
     -- Case 1. Pick - Serial reservation  exisit for the total requested qty
     -- Case 2. Pick- detailed reservations exisit and org-level override rule flag
     --         from the mtl_parameters is 'Yes' - OPM case
     -- Case 3. Put away - For pickrelease and if destnation locator exisit
     -- Case 4. Putaway - For non WMS enabled org, do not call putaway rules
     -- Case 5. Putaway - For Crossdock putaaway , do not call putaway rules
     --
     --]
     IF g_use_rule = 'N' THEN
	g_use_rule := 'Y';
	l_rule_id :=   -999;
	l_strategy_id  := NULL;
     END IF;
    --
    -- For put away strategy and rule, set type code to put away on
    -- second time through the loop.  Type code for putaway full is
    -- set above
    IF  l_simulation_mode IN (g_put_strategy_mode, g_put_rule_mode)
	AND l_counter = 2 THEN
      l_type_code  := 1;
    END IF;
    -- record the strategy ids in the package globals
    IF l_counter = 1 THEN
      IF l_type_code = 2 THEN
	l_request_context.pick_strategy_id  := l_strategy_id;
      ELSE
	l_request_context.put_away_strategy_id  := l_strategy_id;
      END IF;
    ELSE
      l_request_context.put_away_strategy_id  := l_strategy_id;
END IF;

--]]
-------------------------
      display_temp_records;
      IF l_debug = 1 THEN
         log_event(l_api_name,'Engine_pvt', 'Calling wms_strategy.apply()' );
         log_statement(l_api_name, 'Engine_pvt', 'Begin allocating ' || 'for strategy: ' || l_strategy_id);
      End if;
      -- If pick release then no strategy or Rule
      --IF is_pickrelease AND l_type_code = 1 AND l_locator_id IS NOT NULL THEN
      IF (is_pickrelease OR p_wave_simulation_mode = 'Y') AND l_type_code = 1 AND l_locator_id IS NOT NULL THEN
         l_strategy_id := NULL;
      END IF;

         wms_strategy_pvt.apply
           (
            p_api_version           => 1.0,
            p_init_msg_list         => fnd_api.g_false,
            p_validation_level      => fnd_api.g_valid_level_none,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data,
            p_transaction_temp_id   => p_transaction_temp_id,
            p_type_code             => l_type_code,
            p_strategy_id           => l_strategy_id,
            p_rule_id               => l_rule_id,
            p_detail_serial         => l_request_context.detail_serial,
            p_from_serial           => l_request_line_rec.serial_number_start,
            p_to_serial             => l_request_line_rec.serial_number_end,
            p_detail_any_serial     => l_request_context.detail_any_serial,
            p_unit_volume           => l_request_context.unit_volume,
            p_volume_uom_code       => l_request_context.volume_uom_code,
            p_unit_weight           => l_request_context.unit_weight,
            p_weight_uom_code       => l_request_context.weight_uom_code,
            p_base_uom_code         => l_request_context.base_uom_code,
            p_lpn_id                => l_request_line_rec.lpn_id,
            p_unit_number           => l_unit_number,
            p_allow_non_partial_rules => l_allow_non_partial_rules,
            p_simulation_mode         => l_simulation_mode,
            p_simulation_id           => p_simulation_id,
            p_project_id              => l_project_id,
            p_task_id                 => l_task_id,
            p_quick_pick_flag         => l_quick_pick_flag,
	    p_wave_simulation_mode       => p_wave_simulation_mode
            );
       --Bug3237702 ends
       -- IF (l_current_release_level >= l_j_release_level ) THEN  -- Commented for Bug# 4006426
           IF  l_quick_Pick_flag = 'Y'  and l_type_code = 2 then
              l_quick_Pick_flag := 'N';
              IF l_debug = 1  THEN
                 log_event(l_api_name, ' Create suggestions', ' Setting the value of l_quick_Pick');
              END IF;
              IF l_return_status <> fnd_api.g_ret_sts_success then
                 RAISE fnd_api.g_exc_error;
              ELSE
                 IF ((WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE  = 'WMS_ATT_SUB_STATUS_NA' ) or
                    (WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE  = 'WMS_ATT_SERIAL_STATUS_NA' )) then
                    IF l_debug = 1 THEN
                       log_event(l_api_name, 'Create Suggestions',
                              'Quick Pick Validation failure message '
                             || WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE );
                    END IF;
                    ROLLBACK TO create_suggestions_sa;
                    exit;
                 END IF;
              END IF;
            END IF;
    /* Commented for  Bug #4006426
           ELSE
            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               RAISE fnd_api.g_exc_error;
            END IF;
       END IF;
    */
       display_temp_records;
     END LOOP;
    --
    --

    IF l_revert_capacity THEN

      IF l_debug = 1 THEN
          log_event(l_api_name, 'Create Suggestions',
                    'calling rollback_capacity for item '
                    || l_request_line_rec.inventory_item_id);
      END IF;

      wms_rule_pvt.rollback_capacity_update(
        x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_organization_id            => l_request_line_rec.organization_id
      , p_inventory_item_id          => l_request_line_rec.inventory_item_id
      );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF l_debug = 1 THEN
           log_event(l_api_name, 'Create Suggestions','err in rollback_capacity: '|| l_msg_data);
        END IF;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Insert rows to MTL_MATERIAL_TRANSACTIONS_TEMP,
    -- MTL_TRANSACTIONLOTS_TEMP, MTL_SERIAL_NUMBERS_TEMP.
    -- For transfers combine issue and receipt suggestions
    -- to complete transfer transaction
    -- Skip this step when simulating rule or strategy; we want to
    -- keep records in WTT, and don't want to insert into MMTT.

    -- Fix for Bug#8421562 . Added g_available_inventory in following if clause as
    -- Records in GTT should be deleted if Select Available inventory form is called
    -- multiple times in a single session with same move_order_line_id

    IF l_simulation_mode IN (g_full_simulation, g_no_simulation, g_available_inventory ) THEN
      --added by jcearley on 11/22/99 - output table must be initialized
      inv_detail_util_pvt.init_output_process_tbl;

      IF l_request_context.transaction_action_id IN (2, 3, 28) THEN
        combine_transfer(l_return_status, l_request_line_rec, l_request_context, p_plan_tasks);
      ELSE
        output_issue_or_receipt(l_return_status, l_request_line_rec, l_request_context, p_plan_tasks);
      END IF;

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF  l_simulation_mode = g_no_simulation
          AND wms_rule_pvt.isruledebugon(l_simulation_mode) THEN
        --call insert run time trace lines

          IF l_debug = 1 THEN
             log_procedure(l_api_name, 'insert_txn_trace_rows',
                        'Calling insert_txn_trace_rows ');
          END IF;
        wms_search_order_globals_pvt.insert_txn_trace_rows(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_false
        , p_validation_level           => fnd_api.g_valid_level_full
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data
        , p_txn_header_id              => inv_detail_util_pvt.g_transaction_header_id
        , p_insert_lot_flag            => inv_detail_util_pvt.g_insert_lot_flag
        , p_insert_serial_flag         => inv_detail_util_pvt.g_insert_serial_flag
        );
      END IF;

      -- Delete records from WMS_TRANSACTIONS_TEMP
      purge_detail_temp_records(l_return_status, l_request_line_rec);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    --
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

   /*-- debugging section
    -- can be commented out for final code
    IF inv_pp_debug.is_debug_mode THEN
      inv_pp_debug.send_message_to_pipe('exit '|| g_pkg_name || '.' || l_api_name);
    END IF; */

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'exit' , g_pkg_name || '.' || l_api_name);
    END IF;

    --  Patchset 'J' : New Error_messages
    --  Adding the Suggestion failure message to the message stack
    x_msg_data := nvl(WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE, '');

    --BUG 3440344: We should not add message to the stack if
    --G_SUGG_FAILURE_MESSAGE is null
    IF x_msg_data IS NOT NULL OR x_msg_data <> '' THEN
       FND_MESSAGE.SET_NAME('WMS',WMS_ENGINE_PVT.G_SUGG_FAILURE_MESSAGE);
       FND_MSG_PUB.ADD;
    END IF;

    IF l_debug = 1 THEN
       log_procedure(l_api_name, 'end G_SUGG_FAILURE_MESSAGE', x_msg_data );
       log_procedure(l_api_name, 'End', 'End create_suggestions');
    END IF;
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_suggestions_sa;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'error', 'Error in create_suggestions - ' || x_msg_data);
      END IF ;
    --
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_suggestions_sa;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
      log_error(l_api_name, 'unexp_error', 'Unexpected error ' || 'in create_suggestions - ' || x_msg_data);
      END IF;
     --
    WHEN OTHERS THEN
      ROLLBACK TO create_suggestions_sa;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      IF l_debug = 1 THEN
         log_error(l_api_name, 'other_error', 'Other error ' || 'in create_suggestions - ' || x_msg_data);
      END IF;

  END create_suggestions;
--
END wms_engine_pvt;

/

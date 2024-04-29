--------------------------------------------------------
--  DDL for Package Body INV_LOT_TRX_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_TRX_VALIDATION_PUB" AS
/* $Header: INVPLTVB.pls 120.14.12010000.8 2012/07/11 09:31:42 rdudani ship $ */
  PROCEDURE print_debug (p_message IN VARCHAR2, p_module IN VARCHAR2)
  IS
    l_debug   NUMBER;
  BEGIN

    l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

    --dbms_output.put_line(g_pkg_name||'.'||p_module||': ' || p_message);
    IF (l_debug = 1)
    THEN
      inv_log_util.TRACE (p_message, g_pkg_name || '.' || p_module, 9);
      --dbms_output.put_line(substr(p_message,1,200));
    END IF;
  END print_debug;

  /** This procedure gets the wms_installed_flag, wsm_enabled flag and wms_enabled flag **/
  PROCEDURE get_org_info (
    x_wms_installed     OUT NOCOPY      VARCHAR2
  , x_wsm_enabled       OUT NOCOPY      VARCHAR2
  , x_wms_enabled       OUT NOCOPY      VARCHAR2
  , x_return_status     OUT NOCOPY      VARCHAR2
  , x_msg_count         OUT NOCOPY      NUMBER
  , x_msg_data          OUT NOCOPY      VARCHAR2
  , p_organization_id   IN              NUMBER
  )
  IS
    l_wms_installed   VARCHAR2 (1);
    l_debug           NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    BEGIN
      inv_txn_validations.check_wms_install
                                         (x_return_status     => x_wms_installed
                                        , p_msg_count         => x_msg_count
                                        , p_msg_data          => x_msg_data
                                        , p_org               => NULL
                                         );
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('WMS', 'WMS_INSTALL_CHK_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    SELECT wsm_enabled_flag
      INTO x_wsm_enabled
      FROM mtl_parameters
     WHERE organization_id = p_organization_id;

    BEGIN
      inv_txn_validations.check_wms_install
                                           (x_return_status     => x_wms_enabled
                                          , p_msg_count         => x_msg_count
                                          , p_msg_data          => x_msg_data
                                          , p_org               => p_organization_id
                                           );
    EXCEPTION
      WHEN OTHERS
      THEN
        fnd_message.set_name ('WMS', 'WMS_INSTALL_CHK_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      fnd_message.set_name ('INV', 'INV_INVALID_ORG');
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Get_Org_info');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END get_org_info;

  /*********************************************************************************************
   * Validate Lots -- See documentation on the package specification.                        *
   * Pseudo-code:                        *
   * if( p_transaction_Type_id is NULL or p_st_lot_num_tbl.COUNT = 0 OR      *
   *       p_rs_lot_num_tbl.COUNT = 0 or p_st_org_id_tbl.COUNT = 0 OR p_rs_org_id_tbl.COUNT=0  *
   *     OR p_st_item_id_tbl.COUNT=0 OR p_rs_item_id_tbl.COUNT=0 ) Then      *
   *     Return error, missing required parameter            *
   *   end if;                     *
   *                           *
   * l_start_count := p_st_lot_num_tbl.COUNT;            *
   * l_result_count := p_rs_lot_num_Tbl.COUNT;           *
   *                       *
   *    if( this is a lot split transactions ) THEN            *
   *      if l_start_count > 1 then                *
   *   return too many starting lot error            *
   *      end if;                    *
   *      if l_result_Count < 2 then               *
   *   return too few resulting lot error            *
   *      end if;                    *
   *      For each resulting lots LOOP             *
   *   If result lot org Id <> starting lot org id then        *
   *      Return error different org id            *
   *   End if;                   *
   *   If item id of the result lot <> item id of the start lot then     *
   *      Return different item error              *
   *   End if;                   *
   *      End loop;                    *
   *  Else if this is a lot merge transactions then            *
   *      If( l_start_count < 2 ) then               *
   *              Return too few starting lot error            *
   *         End if;                   *
   *         If l_result_count > 2 ) then              *
   *         Return too many result lot error            *
   *         End if;                   *
   *         For each start lot loop               *
   *         If org_id is current start lot different from org id of       *
   *                the previous start lot then            *
   *            Return different org id error            *
   *         End if;                   *
   *         If org id of current start lot different from org id of result lot then   *
   *            Return different org id error.           *
   *         End if;                   *
   *         If item id of current start lot different from item id of the previous    *
   *            Start lot then               *
   *            Return different item id error           *
   *         End if;                   *
   *         If item id of current start lot different from item id of result lot then *
   *            Return different item id error           *
   *       End if;                   *
   *         End loop;                   *
   * Else if this is a lot translate transaction then          *
   *      If l_start_count > 1 then                *
   *              Return too many starting lot error           *
   *          End if;                    *
   *      If l_result_Count > 1 then               *
   *          Return too many result lot error           *
   *          End if;                    *
   *          If org id of start lot different from org id of result lot then      *
   *          Return different org id error              *
   *      End if;                    *
   *      Call validate_lot_translate              *
   *      Return error if validate_lot_translate errored out.        *
   *   End if;                     *
   *********************************************************************************************/
  PROCEDURE validate_lots (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , x_validation_status     OUT NOCOPY      VARCHAR2
  , p_transaction_type_id   IN              NUMBER
  , p_st_org_id_tbl         IN              number_table
  , p_rs_org_id_tbl         IN              number_table
  , p_st_item_id_tbl        IN              number_table
  , p_rs_item_id_tbl        IN              number_table
  , p_st_lot_num_tbl        IN              lot_number_table
  , p_rs_lot_num_tbl        IN              lot_number_table
  , p_st_revision_tbl       IN              revision_table
  , p_rs_revision_tbl       IN              revision_table
  , p_st_quantity_tbl       IN              number_table
  , p_rs_quantity_tbl       IN              number_table
  , p_st_lot_exp_tbl        IN              date_table
  , p_rs_lot_exp_tbl        IN              date_table
  )
  IS
    l_start_count              NUMBER;
    l_result_count             NUMBER;
    l_st_lot_control_code      NUMBER;
    l_st_serial_control_code   NUMBER;
    l_rs_lot_control_code      NUMBER;
    l_rs_serial_control_code   NUMBER;
    l_debug                    NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1)
    THEN
      print_debug ('Inside Validate_Lots', 'Validate_Lots');
      print_debug ('p_transaction_type_id is ' || p_transaction_type_id
                 , 'Validate_lots'
                  );
      print_debug ('p_st_org_id_tbl.COUNT is ' || p_st_org_id_tbl.COUNT
                 , 'Validate_lots'
                  );
      print_debug ('p_rs_org_id_tbl.COUNT is ' || p_rs_org_id_tbl.COUNT
                 , 'Validate_lots'
                  );
      print_debug ('p_st_item_id_tbl.COUNT is ' || p_st_item_id_tbl.COUNT
                 , 'Validate_lots'
                  );
      print_debug ('p_rs_item_id_tbl.COUNT is ' || p_rs_item_id_tbl.COUNT
                 , 'Validate_lots'
                  );
      print_debug ('p_st_lot_num_tbl.COUNT is ' || p_st_lot_num_tbl.COUNT
                 , 'Validate_lots'
                  );
      print_debug ('p_rs_lot_num_tbl.COUNT is ' || p_rs_lot_num_tbl.COUNT
                 , 'Validate_lots'
                  );
    END IF;

    IF (   p_transaction_type_id IS NULL
        OR p_st_lot_num_tbl.COUNT = 0
        OR p_st_lot_num_tbl IS NULL
        OR p_rs_lot_num_tbl.COUNT = 0
        OR p_rs_lot_num_tbl IS NULL
       )
    THEN
      x_validation_status := 'N';
      fnd_message.set_name ('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_start_count := p_st_lot_num_tbl.COUNT;
    l_result_count := p_rs_lot_num_tbl.COUNT;

    IF (l_debug = 1)
    THEN
      print_debug ('l_start_count is ' || l_start_count, 'Validate_Lots');
      print_debug ('l_result_count is ' || l_result_count, 'Validate_Lots');
    END IF;

    IF (p_transaction_type_id = inv_globals.g_type_inv_lot_split)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('validate for lot split', 'Validate_Lots');
      END IF;

      IF (l_start_count > 1)
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('INV_TOO_MANY_LOT_SPLIT', 'Validate_Lots');
        END IF;

        fnd_message.set_name ('INV', 'INV_TOO_MANY_LOT_SPLIT');
        fnd_msg_pub.ADD;
        x_validation_status := 'N';
        RAISE fnd_api.g_exc_error;
      END IF;

      /*Bug#9317064 The below validation is incorrect as the records,
 * p_st_quantity and p_rs_quantity both will have the split quantity */
/*      IF (l_result_count < 2)
      THEN
        IF (p_st_quantity_tbl (1) <= p_rs_quantity_tbl (1))
        THEN
          -- means this is not a partial split.
          fnd_message.set_name ('INV', 'INV_MIN_LOT_SPLIT');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF; */


      FOR i IN 1 .. l_result_count
      LOOP
        IF (p_rs_org_id_tbl (i) <> p_st_org_id_tbl (1))
        THEN
          fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_ORG');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (p_rs_item_id_tbl (i) <> p_st_item_id_tbl (1))
        THEN
          fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_ITEM');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (NVL (p_rs_revision_tbl (i), 'NULL') <>
                                           NVL (p_rs_revision_tbl (1), 'NULL')
           )
        THEN
          fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_REVISION');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (NVL (TO_CHAR (p_rs_lot_exp_tbl (i), 'DD-MON-RRRR')
               , TO_CHAR (SYSDATE, 'DD-MON-RRRR')
                ) <>
              NVL (TO_CHAR (p_st_lot_exp_tbl (1), 'DD-MON-RRRR')
                 , TO_CHAR (SYSDATE, 'DD-MON-RRRR')
                  )
           )
        THEN
          fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_LOT_EXP_DATE');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP;

      --basically checks if lot split is allowed or not
      validate_start_lot (x_return_status           => x_return_status
                        , x_msg_count               => x_msg_count
                        , x_msg_data                => x_msg_data
                        , x_validation_status       => x_validation_status
                        , p_transaction_type_id     => p_transaction_type_id
                        , p_lot_number              => p_st_lot_num_tbl (1)
                        , p_inventory_item_id       => p_st_item_id_tbl (1)
                        , p_organization_id         => p_st_org_id_tbl (1)
                         );

      IF (x_return_status = fnd_api.g_ret_sts_error)
      THEN
        RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --for lot split checks for lot uniqueness....if across items then no other item
      --should have this lot number
      --if not across items then no lot should exists for this item also....
      validate_result_lot (x_return_status           => x_return_status
                         , x_msg_count               => x_msg_count
                         , x_msg_data                => x_msg_data
                         , x_validation_status       => x_validation_status
                         , p_transaction_type_id     => p_transaction_type_id
                         , p_st_lot_num_tbl          => p_st_lot_num_tbl
                         , p_rs_lot_num_tbl          => p_rs_lot_num_tbl
                         , p_inventory_item_id       => p_rs_item_id_tbl (1)
                         , p_organization_id         => p_rs_org_id_tbl (1)
                          );

      IF (x_return_status = fnd_api.g_ret_sts_error)
      THEN
        RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate)
    THEN
      IF (l_start_count > 1)
      THEN
        fnd_message.set_name ('INV', 'INV_MIN_START_LOT_TRANSLATE');
        fnd_msg_pub.ADD;
        x_validation_status := 'N';
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_result_count > 1)
      THEN
        fnd_message.set_name ('INV', 'INV_MIN_RESULT_LOT_TRANSLATE');
        fnd_msg_pub.ADD;
        x_validation_status := 'N';
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_rs_org_id_tbl (1) <> p_st_org_id_tbl (1))
      THEN
        fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_ORG');
        fnd_msg_pub.ADD;
        x_validation_status := 'N';
        RAISE fnd_api.g_exc_error;
      END IF;

      /*Changes for OSFM Support for Serialized Lot Items*/
      IF (p_st_item_id_tbl (1) <> p_rs_item_id_tbl (1))
      THEN
        SELECT lot_control_code
             , serial_number_control_code
          INTO l_st_lot_control_code
             , l_st_serial_control_code
          FROM mtl_system_items
         WHERE inventory_item_id = p_st_item_id_tbl (1)
           AND organization_id = p_st_org_id_tbl (1);

        SELECT lot_control_code
             , serial_number_control_code
          INTO l_rs_lot_control_code
             , l_rs_serial_control_code
          FROM mtl_system_items
         WHERE inventory_item_id = p_rs_item_id_tbl (1)
           AND organization_id = p_rs_org_id_tbl (1);

        IF (   l_st_lot_control_code <> l_rs_lot_control_code
            OR l_st_serial_control_code <> l_rs_serial_control_code
           )
        THEN
          fnd_message.set_name ('INV', 'INV_LOT_SERIAL_CODE_DIFF');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;


      IF (l_debug = 1)
      THEN
        print_debug ('calling validate_lot_translate', 'Validate_lot');
      END IF;

      validate_lot_translate (x_return_status          => x_return_status
                            , x_msg_count              => x_msg_count
                            , x_msg_data               => x_msg_data
                            , x_validation_status      => x_validation_status
                            , p_start_lot_number       => p_st_lot_num_tbl (1)
                            , p_start_inv_item_id      => p_st_item_id_tbl (1)
                            , p_result_lot_number      => p_rs_lot_num_tbl (1)
                            , p_result_inv_item_id     => p_rs_item_id_tbl (1)
                             );

      IF (l_debug = 1)
      THEN
        print_debug ('after calling validate_lot_translate '
                     || x_return_status
                   , 'Validate_lots'
                    );
      END IF;

      IF (x_return_status = fnd_api.g_ret_sts_error)
      THEN
        RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      validate_start_lot (x_return_status           => x_return_status
                        , x_msg_count               => x_msg_count
                        , x_msg_data                => x_msg_data
                        , x_validation_status       => x_validation_status
                        , p_transaction_type_id     => p_transaction_type_id
                        , p_lot_number              => p_st_lot_num_tbl (1)
                        , p_inventory_item_id       => p_st_item_id_tbl (1)
                        , p_organization_id         => p_st_org_id_tbl (1)
                         );

      IF (x_return_status = fnd_api.g_ret_sts_error)
      THEN
        RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      validate_result_lot (x_return_status           => x_return_status
                         , x_msg_count               => x_msg_count
                         , x_msg_data                => x_msg_data
                         , x_validation_status       => x_validation_status
                         , p_transaction_type_id     => p_transaction_type_id
                         , p_st_lot_num_tbl          => p_st_lot_num_tbl
                         , p_rs_lot_num_tbl          => p_rs_lot_num_tbl
                         , p_inventory_item_id       => p_rs_item_id_tbl (1)
                         , p_organization_id         => p_rs_org_id_tbl (1)
                          );

      IF (x_return_status = fnd_api.g_ret_sts_error)
      THEN
        RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
    THEN
      IF (l_start_count < 2)
      THEN
        fnd_message.set_name ('INV', 'INV_MIN_START_LOT_MERGE');
        fnd_msg_pub.ADD;
        x_validation_status := 'N';
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_result_count > 1)
      THEN
        fnd_message.set_name ('INV', 'INV_MAX_RESULT_LOT_MERGE');
        fnd_msg_pub.ADD;
        x_validation_status := 'N';
        RAISE fnd_api.g_exc_error;
      END IF;

      FOR i IN 1 .. l_start_count
      LOOP
        IF (i < l_start_count)
        THEN
          IF (p_st_org_id_tbl (i) <> p_st_org_id_tbl (i + 1))
          THEN
            fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_ORG');
            fnd_msg_pub.ADD;
            x_validation_status := 'N';
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        IF (p_st_org_id_tbl (i) <> p_rs_org_id_tbl (1))
        THEN
          fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_ORG');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (i < l_start_count)
        THEN
          IF (p_st_item_id_tbl (i) <> p_st_item_id_tbl (i + 1))
          THEN
            fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_ITEM');
            fnd_msg_pub.ADD;
            x_validation_status := 'N';
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        IF (p_st_item_id_tbl (i) <> p_rs_item_id_tbl (1))
        THEN
          fnd_message.set_name ('INV', 'INV_LOT_TRX_DIFF_ITEM');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;

        FOR j IN 1 .. l_start_count
        LOOP
          IF (i <> j)
          THEN
            IF (p_st_lot_num_tbl (i) = p_st_lot_num_tbl (j))
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('Duplicate Lot', 'Validate_lots');
              END IF;

              fnd_message.set_name ('INV', 'INV_DUPLICATE_LOT');
              fnd_msg_pub.ADD;
              x_validation_status := 'N';
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END LOOP;

        validate_start_lot (x_return_status           => x_return_status
                          , x_msg_count               => x_msg_count
                          , x_msg_data                => x_msg_data
                          , x_validation_status       => x_validation_status
                          , p_transaction_type_id     => p_transaction_type_id
                          , p_lot_number              => p_st_lot_num_tbl (i)
                          , p_inventory_item_id       => p_st_item_id_tbl (i)
                          , p_organization_id         => p_st_org_id_tbl (i)
                           );

        IF (x_return_status = fnd_api.g_ret_sts_error)
        THEN
          RAISE fnd_api.g_exc_error;
        ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
        THEN
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END LOOP;

      validate_result_lot (x_return_status           => x_return_status
                         , x_msg_count               => x_msg_count
                         , x_msg_data                => x_msg_data
                         , x_validation_status       => x_validation_status
                         , p_transaction_type_id     => p_transaction_type_id
                         , p_st_lot_num_tbl          => p_st_lot_num_tbl
                         , p_rs_lot_num_tbl          => p_rs_lot_num_tbl
                         , p_inventory_item_id       => p_rs_item_id_tbl (1)
                         , p_organization_id         => p_rs_org_id_tbl (1)
                          );

      IF (x_return_status = fnd_api.g_ret_sts_error)
      THEN
        RAISE fnd_api.g_exc_error;
      ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
      THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END IF;

    x_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_validation_status := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_validation_status := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_validation_status := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Lots');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_lots;

  /*********************************************************************************************
   * Pseudo-code:                                                                              *
   *   -- check if all the required parameter is there                                         *
   * if( p_transaction_Type_id is NULL or p_lot_number IS NULL OR p_organization_ID is NULL    *
   *     OR p_inventory_item_id IS NULL ) Then                                                 *
   *     Return error, missing required parameter            *
   * end if;                     *
   *                           *
   *    if( this is a lot split transactions ) THEN            *
   *      Retrieve the lot_split_enabled flag for the item and lot       *
   *      If no data found then                *
   *   Return invalid item error             *
   *      End if;                    *
   * Else if this is a lot merge transactions then           *
   *      Retrieve the lot_merge_enabled flag for the item and lot       *
   *      If no data found then                *
   *   Return invalid item error             *
   *      End if;                    *
   * Else if this is a lot translate transaction then          *
   *      Retrieve the lot_control_code of the item and lot.         *
   *      If the item is lot control then              *
   *   Return 'Y'                  *
   *      Else                   *
   *   Return 'N'                  *
   *      End if;                    *
   * End if;                     *
   *********************************************************************************************/
  PROCEDURE validate_start_lot (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , x_validation_status     OUT NOCOPY      VARCHAR2
  , p_transaction_type_id   IN              NUMBER
  , p_lot_number            IN              VARCHAR2
  , p_inventory_item_id     IN              NUMBER
  , p_organization_id       IN              NUMBER
  )
  IS
    l_validation_status   VARCHAR2 (1);
    l_debug               NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1)
    THEN
      print_debug ('Inside Validate Start Lot ', 'Validate_Start_Lot');
      print_debug ('p_organization_id is ' || p_organization_id
                 , 'Validate_Start_lot'
                  );
      print_debug ('p_inventory_item_id is ' || p_inventory_item_id
                 , 'Validate_Start_lot'
                  );
      print_debug ('p_lot_number is ' || p_lot_number, 'Validate_Start_Lot');
      print_debug ('p_transaction_Type_id is ' || p_transaction_type_id
                 , 'Validate_Start_Lot'
                  );
    END IF;

    IF (   p_transaction_type_id IS NULL
        OR p_lot_number IS NULL
        OR p_organization_id IS NULL
        OR p_inventory_item_id IS NULL
       )
    THEN
      fnd_message.set_name ('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_transaction_type_id = inv_globals.g_type_inv_lot_split)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('validate Start Lot for lot split'
                   , 'Validate_Start_Lot');
      END IF;

      BEGIN
        SELECT msik.lot_split_enabled
          INTO l_validation_status
          FROM mtl_system_items_b msik, mtl_lot_numbers mln
         WHERE mln.organization_id = p_organization_id
           AND mln.inventory_item_id = p_inventory_item_id
           AND mln.lot_number = p_lot_number
           AND mln.organization_id = msik.organization_id
           AND mln.inventory_item_id = msik.inventory_item_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          BEGIN
            SELECT msik.lot_split_enabled
              INTO l_validation_status
              FROM mtl_system_items_b msik
                 , mtl_transaction_lots_temp mtlt
                 , mtl_material_transactions_temp mmtt
             WHERE mmtt.organization_id = p_organization_id
               AND mmtt.inventory_item_id = p_inventory_item_id
               AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
               AND mtlt.lot_number = p_lot_number
               AND mmtt.organization_id = msik.organization_id
               AND mmtt.inventory_item_id = msik.inventory_item_id;
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('no data found in validate lot split'
                           , 'Validate_Start_lot'
                            );
              END IF;

              /* Bug:4405157. Modified the following message to be more specific to
                 Split transaction W.R.T Issue 15 of the bug*/
              fnd_message.set_name ('INV', 'INV_INVALID_LOT_ITEM_LOT_SPLIT');
              fnd_msg_pub.ADD;
	RAISE fnd_api.g_exc_unexpected_error;
          END;
      END;
    ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('validate Start Lot for lot merge'
                   , 'Validate_Start_Lot');
      END IF;

      BEGIN
        SELECT msik.lot_merge_enabled
          INTO l_validation_status
          FROM mtl_system_items_b msik, mtl_lot_numbers mln
         WHERE mln.organization_id = p_organization_id
           AND mln.inventory_item_id = p_inventory_item_id
           AND mln.lot_number = p_lot_number
           AND mln.organization_id = msik.organization_id
           AND mln.inventory_item_id = msik.inventory_item_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          BEGIN
            SELECT msik.lot_merge_enabled
              INTO l_validation_status
              FROM mtl_system_items_b msik
                 , mtl_transaction_lots_temp mln
                 , mtl_material_transactions_temp mmtt
             WHERE mmtt.organization_id = p_organization_id
               AND mmtt.inventory_item_id = p_inventory_item_id
               AND mmtt.transaction_temp_id = mln.transaction_temp_id
               AND mln.lot_number = p_lot_number
               AND mmtt.organization_id = msik.organization_id
               AND mmtt.inventory_item_id = msik.inventory_item_id;
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('no data found in validate lot merge'
                           , 'Validate_Start_lot'
                            );
              END IF;

              /* Bug:4405157. Modified the following message to be more specific to
                 Merge transaction W.R.T Issue 15 of the bug*/
              fnd_message.set_name ('INV', 'INV_INVALID_LOT_ITEM_LOT_MERGE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
          END;
      END;
    ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('validate Start Lot for lot translate'
                   , 'Validate_Start_Lot'
                    );
      END IF;

      BEGIN
        SELECT DECODE (msik.lot_control_code, 2, 'Y', 'N')
          INTO l_validation_status
          FROM mtl_system_items_b msik, mtl_lot_numbers mln
         WHERE mln.organization_id = p_organization_id
           AND mln.inventory_item_id = p_inventory_item_id
           AND mln.lot_number = p_lot_number
           AND mln.organization_id = msik.organization_id
           AND mln.inventory_item_id = msik.inventory_item_id;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          BEGIN
            SELECT DECODE (msik.lot_control_code, 2, 'Y', 'N')
              INTO l_validation_status
              FROM mtl_system_items_b msik
                 , mtl_transaction_lots_temp mln
                 , mtl_material_transactions_temp mmtt
             WHERE mmtt.organization_id = p_organization_id
               AND mmtt.inventory_item_id = p_inventory_item_id
               AND mmtt.transaction_temp_id = mln.transaction_temp_id
               AND mln.lot_number = p_lot_number
               AND mmtt.organization_id = msik.organization_id
               AND mmtt.inventory_item_id = msik.inventory_item_id;
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('no data found in validate lot translate'
                           , 'Validate_Start_lot'
                            );
              END IF;
              /* Bug:4405157. Modified the following message to be more specific to
                 Translate transaction W.R.T Issue 15 of the bug*/
              fnd_message.set_name ('INV', 'INV_INVALID_LOT_ITEM_LOT_XLATE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
          END;
      END;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    x_validation_status := l_validation_status;

    /*Bug:4405157
    /*Added new messages specific to lot split,merge and translate transactions
      W.R.T to issue 15 of the bug*/
    IF (x_validation_status <> 'Y')
    THEN
      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_split)
      THEN

        fnd_message.set_name ('INV', 'INV_INVALID_LOT_ITEM_LOT_SPLIT');

      ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
      THEN

        fnd_message.set_name ('INV', 'INV_INVALID_LOT_ITEM_LOT_MERGE');

      ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate)
      THEN

        fnd_message.set_name ('INV', 'INV_INVALID_LOT_ITEM_LOT_XLATE');

      ELSE
        fnd_message.set_name ('INV', 'INV_INVALID_LOT');
      END IF;
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_validation_status := 'N';
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_validation_status := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_validation_status := 'N';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Start_Lot');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_start_lot;

  /*********************************************************************************************
   * Pseudo-code:                                                                              *
   *   -- check if all the required parameter is there                                         *
   * if( p_transaction_Type_id is NULL or p_lot_number IS NULL OR p_organization_ID is NULL    *
   *     OR p_inventory_item_id IS NULL ) Then                                                 *
   *     Return error, missing required parameter                                              *
   * end if;                                                                                   *
   *                                                                                           *
   *   if( this is a lot split transactions ) THEN                                             *
   *      Retrieve the lot_split_enabled flag for the item and lot                             *
   *      If no data found then                                                                *
   *   Return invalid item error                                                               *
   *      End if;                                                                              *
   * Else if this is a lot merge transactions then                                             *
   *      Retrieve the lot_merge_enabled flag for the item and lot                             *
   *      If no data found then                                                                *
   *   Return invalid item error                                                               *
   *      End if;                                                                              *
   * Else if this is a lot translate transaction then                                          *
   *      Retrieve the lot_control_code of the item and lot.                                   *
   *      If the item is lot control then                                                      *
   *   Return 'Y'                                                                              *
   *      Else                                                                                 *
   *   Return 'N'                                                                              *
   *      End if;                                                                              *
   * End if;                                                                                   *
   *********************************************************************************************/
  PROCEDURE validate_result_lot (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , x_validation_status     OUT NOCOPY      VARCHAR2
  , p_transaction_type_id   IN              NUMBER
  , p_st_lot_num_tbl        IN              lot_number_table
  , p_rs_lot_num_tbl        IN              lot_number_table
  , p_inventory_item_id     IN              NUMBER
  , p_organization_id       IN              NUMBER
  )
  IS
    l_validation_status   VARCHAR2 (1);
    l_lot_uniqueness      NUMBER;
    l_lot_count           NUMBER;
    l_inventory_item_id   NUMBER;
    l_debug               NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1)
    THEN
      print_debug ('Inside Validate_Result_lot', 'Validate_Result_Lot');
      print_debug ('P_organization_id is ' || p_organization_id
                 , 'Validate_Result_Lot'
                  );
      print_debug ('P_inventory_item_id is ' || p_inventory_item_id
                 , 'Validate_Result_Lot'
                  );
      print_debug ('P_transaction_Type_id is ' || p_transaction_type_id
                 , 'Validate_Result_Lot'
                  );
      print_debug ('p_st_lot_num_tbl.count is ' || p_st_lot_num_tbl.COUNT
                 , 'Validate_Result_Lot'
                  );
      print_debug ('p_rs_lot_num_tbl.count is ' || p_rs_lot_num_tbl.COUNT
                 , 'Validate_Result_Lot'
                  );
    END IF;

    IF (   p_transaction_type_id IS NULL
        OR p_st_lot_num_tbl.COUNT = 0
        OR p_rs_lot_num_tbl.COUNT = 0
        OR p_organization_id IS NULL
        OR p_inventory_item_id IS NULL
       )
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('Missing Required Parameter', 'Validate_Result_Lot');
      END IF;

      fnd_message.set_name ('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
    /* Bug#4363274. This check is not required.
    IF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('result lot_num is ' || p_rs_lot_num_tbl (1)
                   , 'Validate_Result_Lot'
                    );
      END IF;

      FOR i IN 1 .. p_st_lot_num_tbl.COUNT
      LOOP
        IF (l_debug = 1)
        THEN
          print_debug ('lot_num ' || i || ' is ' || p_st_lot_num_tbl (i)
                     , 'Validate_Result_Lot'
                      );
        END IF;

        IF (p_st_lot_num_tbl (i) = p_rs_lot_num_tbl (1))
        THEN
          fnd_message.set_name ('INV', 'INV_MERGELOT_USED');
          fnd_msg_pub.ADD;
          l_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP;
    END IF;
    */

    BEGIN
      SELECT lot_number_uniqueness
        INTO l_lot_uniqueness
        FROM mtl_parameters
       WHERE organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        fnd_message.set_name ('INV', 'INV_INT_ORG_CODE');
        fnd_msg_pub.ADD;
        x_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (l_debug = 1)
    THEN
      print_debug ('l_lot_uniqueness is ' || l_lot_uniqueness
                 , 'Validate_Result_Lot'
                  );
    END IF;

    IF (l_lot_uniqueness = 1)
    THEN
      -- lot number is unique accross items
      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_split)
      THEN
        FOR i IN 1 .. p_rs_lot_num_tbl.COUNT
        LOOP
          SELECT COUNT (1)
            INTO l_lot_count
            FROM mtl_lot_numbers
           WHERE inventory_item_id <> p_inventory_item_id
             AND organization_id = p_organization_id
             AND lot_number = p_rs_lot_num_tbl (i);

          IF (l_lot_count > 0)
          THEN
            l_validation_status := 'N';
            fnd_message.set_name ('INV', 'INV_INT_LOTUNIQEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          ELSE
            l_validation_status := 'Y';
          END IF;

          SELECT COUNT (1)
            INTO l_lot_count
            FROM mtl_transaction_lots_temp mtlt
               , mtl_material_transactions_temp mmtt
           WHERE mmtt.inventory_item_id <> p_inventory_item_id
             AND mmtt.organization_id = p_organization_id
             AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
             AND mtlt.lot_number = p_rs_lot_num_tbl (i);

          IF (l_lot_count > 0)
          THEN
            l_validation_status := 'N';
            fnd_message.set_name ('INV', 'INV_INT_LOTUNIQEXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          ELSE
            l_validation_status := 'Y';
          END IF;

          FOR j IN 1 .. p_rs_lot_num_tbl.COUNT
          LOOP
            IF (i <> j)
            THEN
              IF (p_rs_lot_num_tbl (i) = p_rs_lot_num_tbl (j))
              THEN
                IF (l_debug = 1)
                THEN
                  print_debug ('Duplicate Lot', 'Validate_Result_Lot');
                END IF;

                l_validation_status := 'N';
                fnd_message.set_name ('INV', 'INV_DUPLICATE_LOT');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;
          END LOOP;
        END LOOP;
      ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate)
      THEN
        IF (p_st_lot_num_tbl (1) <> p_rs_lot_num_tbl (1))
        THEN
	  l_validation_status := 'Y';
        END IF;
      ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
      THEN
        SELECT COUNT (1)
          INTO l_lot_count
          FROM mtl_lot_numbers
         WHERE inventory_item_id <> p_inventory_item_id
           AND organization_id = p_organization_id
           AND lot_number = p_rs_lot_num_tbl (1);

        IF (l_lot_count > 0)
        THEN
          -- this means the lot number exists for different item.
          -- for lot merge, the resultant lot can be an existing item, but of the same item,
          -- cannot be from different items.
          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_INT_LOTUNIQEXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          l_validation_status := 'Y';
        END IF;

        SELECT COUNT (1)
          INTO l_lot_count
          FROM mtl_transaction_lots_temp mtlt
             , mtl_material_transactions_temp mmtt
         WHERE mmtt.inventory_item_id <> p_inventory_item_id
           AND mmtt.organization_id = p_organization_id
           AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
           AND mtlt.lot_number = p_rs_lot_num_tbl (1);

        IF (l_lot_count > 0)
        THEN
          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_INT_LOTUNIQEXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          l_validation_status := 'Y';
        END IF;
      END IF;
    END IF;

    -- here is lot number uniqueness is none.
    IF (p_transaction_type_id = inv_globals.g_type_inv_lot_split)
    THEN
      FOR i IN 1 .. p_rs_lot_num_tbl.COUNT
      LOOP
        SELECT COUNT (1)
          INTO l_lot_count
          FROM mtl_lot_numbers
         WHERE inventory_item_id = p_inventory_item_id
           AND organization_id = p_organization_id
           AND lot_number = p_rs_lot_num_tbl (i);

        IF (l_lot_count > 0)
        THEN
          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_LOT_EXISTS');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          l_validation_status := 'Y';
        END IF;

        -- this is for specific OSFM validation
        SELECT COUNT (1)
          INTO l_lot_count
          FROM wip_entities
         WHERE wip_entity_name = p_rs_lot_num_tbl (i)
           AND organization_id = p_organization_id;

        IF l_lot_count > 0
        THEN
          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_LOT_EXISTS');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          l_validation_status := 'Y';
        END IF;

        SELECT COUNT (1)
          INTO l_lot_count
          FROM mtl_transaction_lots_temp mtlt
             , mtl_material_transactions_temp mmtt
         WHERE mmtt.inventory_item_id = p_inventory_item_id
           AND mmtt.organization_id = p_organization_id
           AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
           AND mtlt.lot_number = p_rs_lot_num_tbl (i);

        IF l_lot_count > 0
        THEN
          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_LOT_EXISTS');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          l_validation_status := 'Y';
        END IF;

        FOR j IN 1 .. p_rs_lot_num_tbl.COUNT
        LOOP
          IF (i <> j)
          THEN
            IF (p_rs_lot_num_tbl (i) = p_rs_lot_num_tbl (j))
            THEN
              IF (l_debug = 1)
              THEN
                print_debug ('Duplicate Lot', 'Validate_Result_Lot');
              END IF;

              l_validation_status := 'N';
              fnd_message.set_name ('INV', 'INV_DUPLICATE_LOT');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END LOOP;
      END LOOP;
    ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('start lot = ' || p_st_lot_num_tbl (1)
                   , 'Validate_Result_Lot'
                    );
        print_debug ('result lot = ' || p_rs_lot_num_tbl (1)
                   , 'Validate_Result_Lot'
                    );
      END IF;

      IF (p_st_lot_num_tbl (1) <> p_rs_lot_num_tbl (1))
      THEN
	l_validation_status := 'Y';

        SELECT COUNT (1)
          INTO l_lot_count
          FROM wip_entities
         WHERE organization_id = p_organization_id
           AND wip_entity_name = p_rs_lot_num_tbl (1);

        IF l_lot_count > 0
        THEN
          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_LOT_EXISTS');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          l_validation_status := 'Y';
        END IF;

      END IF;
    ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug
                ('validate result lot for lot uniqueness is 2 for lot merge'
               , 'validate_result_lot'
                );
      END IF;
/*
  for l_lot_csr in lot_num_csr(p_rs_lot_num_tbl(1), p_organization_id) LOOP
      IF (l_debug = 1) THEN
        print_debug('l_inventory_item_id is ' || l_lot_csr.inventory_item_id, 'validate_result_lot');
      END IF;
      if( l_lot_csr.inventory_item_id = p_inventory_item_id ) then
    l_found := true;
      end if;
  end loop;

  if( l_found = false ) then
      FND_MESSAGE.SET_NAME('INV', 'INV_DIFF_MERGE_ITEM');
      FND_MSG_PUB.ADD;
            l_validation_status := 'N';
      raise FND_API.G_EXC_ERROR;
  end if;
  IF (l_debug = 1) THEN
    print_Debug('after validating the item', 'validate_result_lot');
  END IF;

  SELECT count(1)
  INTO l_lot_count
  FROM mtl_lot_numbers
  WHERE inventory_item_id = p_inventory_item_id
  AND   organization_id = p_organization_id
  AND lot_number = p_rs_lot_num_tbl(1);

  if( l_lot_count = 0 ) then
      IF (l_debug = 1) THEN
        print_debug('after validating against mtl_lot_numbers', 'validate_result_lot');
      END IF;
      SELECT count(1)
      INTO l_lot_count
      FROM   WIP_ENTITIES
      WHERE  organization_id = p_organization_id
      AND    wip_entity_name = p_rs_lot_num_tbl(1);

      if( l_lot_count = 0 ) then
          IF (l_debug = 1) THEN
            print_debug('after validating against wip_entities', 'validate_result_lot');
          END IF;
          SELECT COUNT(1)
          INTO   l_lot_count
          FROM   MTL_TRANSACTION_LOTS_TEMP MTLT, MTL_MATERIAL_TRANSACTIONS_TEMP MMTT
          WHERE  mmtt.inventory_item_id = p_inventory_item_id
          AND    mmtt.organization_id = p_organization_id
          AND    Mmtt.transaction_temp_id = MTLT.transaction_temp_id
          AND    mtlt.lot_number = p_rs_lot_num_tbl(1);

          IF l_lot_count = 0 Then
             l_validation_status := 'N';
             FND_MESSAGE.SET_NAME('INV', 'INV_INVALID_LOT');
             FND_MSG_PUB.ADD;
             raise FND_API.G_EXC_ERROR;
          else
             l_validation_status := 'Y';
          end if;
          IF (l_debug = 1) THEN
            print_debug('after validating against mtl_transaction_lots_temp', 'validate_result_lot');
          END IF;
     else
         l_validation_status := 'Y';
     end if;
  else
     l_validation_status := 'Y';
  end if;
*/
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    x_validation_status := l_validation_status;

    IF (x_validation_status <> 'Y')
    THEN
      fnd_message.set_name ('INV', 'INV_INVALID_LOT');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name
                               , 'Validate_Result_Lot_Uniqueness');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_result_lot;

  /*********************************************************************************************
   *  Pseudo - code:                                                                           *
   * if( p_start_lot_number IS NULL OR p_result_lot_number IS NULL OR                          *
   *            p_start_inv_item_id IS NULL OR p_result_inv_item_id IS NULL ) THEN             *
   *     return missing required parameter error                                               *
   * end if;                                                                                   *
   *                                                                                           *
   *   if( p_start_lot_number = p_result_lot_number ) then                                     *
   *    if( p_start_inv_item_id = p_result_inv_item_id ) then                                  *
   *        return 'N';                                                                        *
   *    else                                                                                   *
   *        return 'Y';                                                                        *
   *    end if;                                                                                *
   * else                                                                                      *
   *    if( p_start_inv_item_id = p_result_inv_item_id ) then                                  *
   *        return  'Y';                                                                       *
   *    else                                                                                   *
   *        return 'N';                                                                        *
   *    end if;                                                                                *
   * end if;                                                                                   *
   *********************************************************************************************/
  PROCEDURE validate_lot_translate (
    x_return_status        OUT NOCOPY      VARCHAR2
  , x_msg_count            OUT NOCOPY      NUMBER
  , x_msg_data             OUT NOCOPY      VARCHAR2
  , x_validation_status    OUT NOCOPY      VARCHAR2
  , p_start_lot_number     IN              VARCHAR2
  , p_start_inv_item_id    IN              NUMBER
  , p_result_lot_number    IN              VARCHAR2
  , p_result_inv_item_id   IN              NUMBER
  )
  IS
    l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1)
    THEN
      print_debug ('Inside Validate_Lot_Translate', 'Validate_Lot_Translate');
      print_debug ('p_start_lot_number is ' || p_start_lot_number
                 , 'Validate_Lot_Translate'
                  );
      print_debug ('p_result_lot_number is ' || p_result_lot_number
                 , 'Validate_Lot_Translate'
                  );
      print_debug ('p_start_inv_item_id is ' || p_start_inv_item_id
                 , 'Validate_Lot_Translate'
                  );
      print_debug ('p_result_inv_item_id is ' || p_result_inv_item_id
                 , 'Validate_Lot_Translate'
                  );
    END IF;

    IF (   p_start_lot_number IS NULL
        OR p_result_lot_number IS NULL
        OR p_start_inv_item_id IS NULL
        OR p_result_inv_item_id IS NULL
       )
    THEN
      fnd_message.set_name ('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      x_validation_status := 'N';
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (p_start_lot_number = p_result_lot_number)
    THEN
      IF (p_start_inv_item_id = p_result_inv_item_id)
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('I am here, x_validation_status is N'
                     , 'Validate_Lot_Translate'
                      );
        END IF;

        x_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_ALREADY_EXISTS');
        fnd_message.set_token ('ENTITY'
                             , fnd_message.get_string ('INV', 'LOT_NUMBER')
                              );
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        x_validation_status := 'Y';
      END IF;
    ELSE
      /*if( p_start_inv_item_id = p_result_inv_item_id ) then
          x_validation_status := 'Y';
      else
          x_validation_status := 'N';
          FND_MESSAGE.SET_NAME('INV', 'INV_ALREADY_EXISTS');
          FND_MESSAGE.SET_TOKEN('ENTITY', FND_MESSAGE.get_String('INV', 'LOT_NUMBER'));
          FND_MSG_PUB.ADD;
          raise FND_API.G_EXC_ERROR;
      end if;*/
      x_validation_status := 'Y';
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Lot_Translate');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_lot_translate;



    /***********************************Validate_LPN_Info*************************
    Perform basic validations for the LPNs present in the Lot transactions.
    -> From LPN should always be in context "Resides in Inventory"
    -> To LPN can be in status 'Resides in Inventory' OR 'Defined but not used'
    -> Validate the org, sub and locator for To LPN
  ****************************************************************************/
  PROCEDURE validate_lpn_info (
    x_return_status            OUT NOCOPY      VARCHAR2
  , x_msg_count                OUT NOCOPY      NUMBER
  , x_msg_data                 OUT NOCOPY      VARCHAR2
  , x_validation_status        OUT NOCOPY      VARCHAR2
  , p_st_lpn_id_tbl            IN              number_table
  , p_rs_lpn_id_tbl            IN              number_table
  , p_st_org_id_tbl            IN              number_table
  , p_rs_org_id_tbl            IN              number_table
  , p_rs_sub_code_tbl          IN              sub_code_table
  , p_rs_locator_id_tbl        IN              number_table
  )
  IS
    l_lpn_context NUMBER;
    l_org_id NUMBER;
    l_sub_code mtl_secondary_inventories.secondary_inventory_name%TYPE;
    l_locator_id NUMBER;
    l_validation_status VARCHAR2(1);
    l_debug NUMBER;
  BEGIN
    l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    x_return_status := fnd_api.g_ret_sts_success;
    l_validation_status := 'Y';

    FOR i IN 1..p_st_lpn_id_tbl.COUNT LOOP
      IF(p_st_lpn_id_tbl(i) IS NOT NULL) THEN
        BEGIN
          SELECT lpn_context
            INTO l_lpn_context
            FROM wms_license_plate_numbers
            WHERE lpn_id = p_st_lpn_id_tbl(i);
        EXCEPTION
          WHEN OTHERS THEN
            l_validation_status := 'N';
            RAISE fnd_api.g_exc_unexpected_error;
        END;
        IF(l_lpn_context <> 1) --does not resides in inventory
        THEN
          fnd_message.set_name('INV', 'INV_INVALID_LPN_CONTEXT');
          fnd_msg_pub.ADD;
          IF (l_debug = 1) THEN
            print_debug('validate_lpn_info: Invalid LPN Context for FROM LPN' , 'validate_lpn_info');
          END IF;
          l_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;
       END IF;
      END LOOP;

    FOR i IN 1..p_rs_lpn_id_tbl.COUNT LOOP
      IF(p_rs_lpn_id_tbl(i) IS NOT NULL) THEN
        BEGIN
          SELECT lpn_context
                ,subinventory_code
                ,locator_id
                ,organization_id
            INTO l_lpn_context
                ,l_sub_code
                ,l_locator_id
                ,l_org_id
            FROM wms_license_plate_numbers
            WHERE lpn_id = p_rs_lpn_id_tbl(i);
        EXCEPTION
          WHEN OTHERS THEN
            l_validation_status := 'N';
            RAISE fnd_api.g_exc_unexpected_error;
        END;
        IF(l_lpn_context NOT IN (1,5)) --does not 'resides in inventory' and not 'defined but not used'
        THEN
          fnd_message.set_name('INV', 'INV_INVALID_LPN_CONTEXT');
          fnd_msg_pub.ADD;
          IF (l_debug = 1) THEN
            print_debug('validate_lpn_info: Invalid LPN Context for TO LPN', 'validate_lpn_info');
          END IF;
          l_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        ELSIF(l_lpn_context = 1) THEN
          IF ( (l_org_id <> p_st_org_id_tbl(1) )
              OR
             (NVL(l_sub_code, '@#$%') <> p_rs_sub_code_tbl(i))
              OR
             (NVL(l_locator_id, -9999) <> NVL(p_rs_locator_id_tbl(i), -9999))
            ) THEN
            fnd_message.set_name('INV', 'INV_INT_LPN');
            fnd_msg_pub.ADD;
            IF (l_debug = 1) THEN
              print_debug('validate_lpn_info: Org/Sub/Loc of LPN does not match', 'validate_lpn_info');
            END IF;
            l_validation_status := 'N';
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
       END IF;
      END LOOP;

      x_validation_status := 'Y';
      x_return_status := fnd_api.g_ret_sts_success;
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN fnd_api.g_exc_error
  THEN
    x_validation_status := l_validation_status;
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (p_count     => x_msg_count
                             , p_data      => x_msg_data);
  WHEN fnd_api.g_exc_unexpected_error
  THEN
    x_validation_status := l_validation_status;
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get (p_count     => x_msg_count
                             , p_data      => x_msg_data);
  WHEN OTHERS
  THEN
    x_validation_status := 'E';
    x_return_status := fnd_api.g_ret_sts_unexp_error;

    IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
    THEN
      fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Lpn_Info');
    END IF;

    fnd_msg_pub.count_and_get (p_count     => x_msg_count
                             , p_data      => x_msg_data);

  END validate_lpn_info;


  /*********************************************************************************************
   * Pseudo - code:                                                                            *
   *   if( p_transaction_type_id IS NULL OR p_lot_number is NULL                               *
   * OR p_organization_id IS NULL OR p_inventory_item_id is NULL ) then                        *
   *     return missing required parameter error                                               *
   *   end if;                                                                                 *
   *                                                                                           *
   *   if( p_status_id is null ) then                                                          *
   *   retrieve the status from mtl_lot_numbers for the lot number into l_status_id            *
   *   If not found then                                                                       *
   *   Return invalid lot number error                                                         *
   *   End if;                                                                                 *
   *   Else                      *
   *   l_status_id := p_status_id;               *
   *   end if;                     *
   *                               *
   *   call inv_material_status_grp.get_lot_serial_status_control to get the     *
   *     lot_status_enabled and default_lot_status_id for the org, item and lot.   *
   *                       *
   *   if( return status Is not success )              *
   *     return validation_status = 'N'              *
   *  end if;                      *
   *                                                                              *
   *  Call Get_Org_info (to get the wms_intalled, wsm_enabled and wms_enabled flag)    *
   *                       *
   *  if( l_status_id IS NULL OR l_wsm_enabled = 'Y' ) then          *
   *   -- no status is assigned and this is an WSM organization, we don't care     *
   *   -- about status                   *
   *   return validation_status = 'Y';               *
   *  else                     *
   * call inv_material_status_grp.is_status_applicable to see if the lot     *
   *   split or lot merge or lot translate is enable or not by the status on     *
   *      the subinventory, locator, organization and lot number       *
   * if status is applicable then                *
   *    return 'Y'                   *
   *   else                      *
   *     return 'N'                    *
   *   end if;                     *
   *  end if;                      *
   **********************************************************************************************/
  PROCEDURE validate_material_status (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , x_validation_status     OUT NOCOPY      VARCHAR2
  , p_transaction_type_id   IN              NUMBER
  , p_organization_id       IN              NUMBER
  , p_inventory_item_id     IN              NUMBER
  , p_lot_number            IN              VARCHAR2
  , p_subinventory_code     IN              VARCHAR2
  , p_locator_id            IN              NUMBER
  , p_status_id             IN              NUMBER
  , p_lpn_id                IN              NUMBER DEFAULT NULL              -- bug 14269152
  )
  IS
    l_validation_status          VARCHAR2 (1);
    l_wms_installed              VARCHAR2 (30);
    l_wms_enabled                VARCHAR2 (1);
    l_wsm_enabled                VARCHAR2 (1);
    l_status_id                  NUMBER;
    l_default_lot_status_id      NUMBER;
    l_lot_status_enabled         VARCHAR2 (10);
    l_serial_status_enabled      VARCHAR2 (10);
    l_default_serial_status_id   NUMBER;
    l_debug                      NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (   p_transaction_type_id IS NULL
        OR p_lot_number IS NULL
        OR p_organization_id IS NULL
        OR p_inventory_item_id IS NULL
       )
    THEN
      fnd_message.set_name ('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      x_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('Inside Validate_Material_Status'
                 , 'Validate_Material_status'
                  );
      print_debug ('p_transaction_Type_id is ' || p_transaction_type_id
                 , 'Validate_Material_status'
                  );
      print_debug ('p_organization_id is ' || p_organization_id
                 , 'Validate_Material_status'
                  );
      print_debug ('p_inventory_item_id is ' || p_inventory_item_id
                 , 'Validate_Material_status'
                  );
      print_debug ('p_lot_number is ' || p_lot_number
                 , 'Validate_Material_status'
                  );
      print_debug ('p_subinventory_code is ' || p_subinventory_code
                 , 'Validate_Material_status'
                  );
      print_debug ('p_status_id is ' || p_status_id
                 , 'Validate_Material_status'
                  );
    END IF;

    IF (p_status_id IS NULL)
    THEN
      BEGIN
        SELECT status_id
          INTO l_status_id
          FROM mtl_lot_numbers
         WHERE organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND lot_number = p_lot_number;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          fnd_message.set_name ('INV', 'INV_INVALID_ATTRIBUTE');
          fnd_message.set_token ('ATTRIBUTE'
                               , fnd_message.get_string ('INV'
                                                       , 'CAPS_LOT_NUMBER'
                                                        )
                               , FALSE
                                );
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
      END;
    ELSE
      l_status_id := p_status_id;
    END IF;

    inv_material_status_grp.get_lot_serial_status_control
                     (p_organization_id              => p_organization_id
                    , p_inventory_item_id            => p_inventory_item_id
                    , x_return_status                => x_return_status
                    , x_msg_data                     => x_msg_data
                    , x_msg_count                    => x_msg_count
                    , x_lot_status_enabled           => l_lot_status_enabled
                    , x_default_lot_status_id        => l_default_lot_status_id
                    , x_serial_status_enabled        => l_serial_status_enabled
                    , x_default_serial_status_id     => l_default_serial_status_id
                     );

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      x_validation_status := 'N';
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_status_id IS NULL)
    THEN
      l_validation_status := 'Y';
    ELSE
      IF (l_debug = 1)
      THEN
        print_debug ('validate subinventory ', 'Validate_Material_status');
      END IF;

      l_validation_status :=
        inv_material_status_grp.is_status_applicable
                          (p_wms_installed             => l_wms_installed
                         , p_trx_status_enabled        => NULL
                         , p_trx_type_id               => p_transaction_type_id
                         , p_lot_status_enabled        => l_lot_status_enabled
                         , p_serial_status_enabled     => l_serial_status_enabled
                         , p_organization_id           => p_organization_id
                         , p_inventory_item_id         => p_inventory_item_id
                         , p_sub_code                  => p_subinventory_code
                         , p_locator_id                => p_locator_id
                         , p_lot_number                => p_lot_number
                         , p_serial_number             => NULL
                         , p_object_type               => 'A'
                         , p_lpn_id                    => p_lpn_id               -- bug 14269152
                          );
    END IF;

    x_validation_status := l_validation_status;
    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Material_Status');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_material_status;

  /****************************************************************************
   * Added For OSFM support for Serialized Lot Items. Mostly the same logic as *
   * the validate_material_status procedure but specific to serial Items       *
  ******************************************************************************/
  PROCEDURE validate_serial_status (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , x_validation_status     OUT NOCOPY      VARCHAR2
  , p_transaction_type_id   IN              NUMBER
  , p_organization_id       IN              NUMBER
  , p_inventory_item_id     IN              NUMBER
  , p_serial_number         IN              VARCHAR2
  , p_subinventory_code     IN              VARCHAR2
  , p_locator_id            IN              NUMBER
  , p_status_id             IN              NUMBER
  )
  IS
    l_validation_status          VARCHAR2 (1);
    l_wms_installed              VARCHAR2 (30);
    l_wms_enabled                VARCHAR2 (1);
    l_wsm_enabled                VARCHAR2 (1);
    l_status_id                  NUMBER;
    l_default_lot_status_id      NUMBER;
    l_lot_status_enabled         VARCHAR2 (10);
    l_serial_status_enabled      VARCHAR2 (10);
    l_default_serial_status_id   NUMBER;
    l_debug                      NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (   p_transaction_type_id IS NULL
        OR p_serial_number IS NULL
        OR p_organization_id IS NULL
        OR p_inventory_item_id IS NULL
       )
    THEN
      fnd_message.set_name ('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      x_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('Inside Validate_Serial_Status'
                 , 'Validate_serial_status'
                  );
      print_debug ('p_transaction_Type_id is ' || p_transaction_type_id
                 , 'Validate_serial_status'
                  );
      print_debug ('p_organization_id is ' || p_organization_id
                 , 'Validate_serial_status'
                  );
      print_debug ('p_inventory_item_id is ' || p_inventory_item_id
                 , 'Validate_serial_status'
                  );
      print_debug ('p_subinventory_code is ' || p_subinventory_code
                 , 'Validate_serial_status'
                  );
      print_debug ('p_status_id is ' || p_status_id, 'Validate_serial_status');
    END IF;

    IF (p_status_id IS NULL)
    THEN
      BEGIN
        IF (l_debug = 1)
        THEN
          print_debug ('get status_id from MSN', 'Validate_serial_status');
        END IF;

        SELECT status_id
          INTO l_status_id
          FROM mtl_serial_numbers
         WHERE current_organization_id = p_organization_id
           AND inventory_item_id = p_inventory_item_id
           AND serial_number = p_serial_number;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('exception fetching status_id from MSN'
                       , 'Validate_serial_status'
                        );
          END IF;

          fnd_message.set_name ('INV', 'INV_INVALID_ATTRIBUTE');
          fnd_message.set_token ('ATTRIBUTE'
                               , fnd_message.get_string ('INV'
                                                       , 'CAPS_SERIAL_NUMBERS'
                                                        )
                               , FALSE
                                );
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
      END;
    ELSE
      l_status_id := p_status_id;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling get_lot_serial_status_control'
                 , 'Validate_serial_status'
                  );
    END IF;

    inv_material_status_grp.get_lot_serial_status_control
                     (p_organization_id              => p_organization_id
                    , p_inventory_item_id            => p_inventory_item_id
                    , x_return_status                => x_return_status
                    , x_msg_data                     => x_msg_data
                    , x_msg_count                    => x_msg_count
                    , x_lot_status_enabled           => l_lot_status_enabled
                    , x_default_lot_status_id        => l_default_lot_status_id
                    , x_serial_status_enabled        => l_serial_status_enabled
                    , x_default_serial_status_id     => l_default_serial_status_id
                     );

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug (' get_lot_serial_status_control returned with error'
                   , 'Validate_serial_status'
                    );
      END IF;

      x_validation_status := 'N';
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_status_id IS NULL)
    THEN
      l_validation_status := 'Y';
    ELSE
      IF (l_debug = 1)
      THEN
        print_debug ('validate subinventory ', 'Validate_Serial_status');
      END IF;

      IF (l_debug = 1)
      THEN
        print_debug ('calling is_status_applicable'
                   , 'Validate_serial_status');
      END IF;

      l_validation_status :=
        inv_material_status_grp.is_status_applicable
                          (p_wms_installed             => l_wms_installed
                         , p_trx_status_enabled        => NULL
                         , p_trx_type_id               => p_transaction_type_id
                         , p_lot_status_enabled        => l_lot_status_enabled
                         , p_serial_status_enabled     => l_serial_status_enabled
                         , p_organization_id           => p_organization_id
                         , p_inventory_item_id         => p_inventory_item_id
                         , p_sub_code                  => p_subinventory_code
                         , p_locator_id                => p_locator_id
                         , p_lot_number                => NULL
                         , p_serial_number             => p_serial_number
                         , p_object_type               => 'A'
                          );

      IF (l_validation_status <> 'Y')
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('calling is_status_applicable returned with error'
                     , 'Validate_serial_status'
                      );
        END IF;

        x_validation_status := l_validation_status;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    x_validation_status := l_validation_status;
    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Serial_Status');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_serial_status;

  /******************************************************************************************
   * populate the global variable g_lot_attributes_tbl with the column name and column type *
   * for the lot attributes                                                                 *
   ******************************************************************************************/
  PROCEDURE populatelotattributes
  IS
    CURSOR column_csr (p_table_name VARCHAR2, p_owner VARCHAR2)
    IS
      SELECT   column_name
             , data_type
          FROM all_tab_columns
         WHERE table_name = p_table_name AND owner = p_owner
               AND column_id > 22
      ORDER BY column_id;

    l_column_idx      BINARY_INTEGER := 0;
    l_ret             BOOLEAN;
    l_status          VARCHAR2 (1);
    l_industry        VARCHAR2 (1);
    l_oracle_schema   VARCHAR2 (30);
    l_debug           NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    l_ret :=
      fnd_installation.get_app_info ('INV'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

    FOR l_column_csr IN column_csr ('MTL_TRANSACTION_LOTS_INTERFACE'
                                  , l_oracle_schema
                                   )
    LOOP
      l_column_idx := l_column_idx + 1;
      g_lot_attributes_tbl (l_column_idx).column_name :=
                                                     l_column_csr.column_name;
      g_lot_attributes_tbl (l_column_idx).column_type :=
                                                       l_column_csr.data_type;
    END LOOP;
  END;

  /*********************************************************************************************
   * Pseudo-codes:                   *
   *  x_return_status := FND_API.G_RET_STS_SUCCESS;
   *  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);
   *
   *  call INV_LOT_SEL_ATTR.is_enabled to see if the lot attributes is enabled for this
   *      item/org/category combination
   *
   *  if no lot attributes is enabled then
   *   return validation status 'Y', we don't need to validate any attributes.
   *  End if;
   *
   *  -- if we are here, means there are some enabled segment, some can be required.
   *  Initialize g_lot_attributes_tbl by calling populateLotAttributes;
   *
   *
   *  if( p_result_lot_attr_tbl.COUNT <> 0 ) then
   * -- user populate the lot attributes data for the resulting lots
   *      for each record in p_result_lot_attr_tbl.COUNT LOOP
   *        for each record in g_lot_attributes_tbl.COUNT LOOP
   *            if( UPPER(g_lot_attributes_tbl(j).COLUMN_NAME) match
   *               UPPER(p_result_lot_attr_tbl(i).COLUMN_NAME) ) then
   *                g_lot_attributes_Tbl(j).COLUMN_VALUE :=
   *                          p_result_lot_attr_tbl(i).COLUMN_VALUE;
   *              end if;
   *              exit when (UPPER(g_lot_attributes_tbl(j).COLUMN_NAME) =
   *                       UPPER(p_result_lot_attr_tbl(i).COLUMN_NAME));
   *          end loop;
   *      end loop;
   *   else
   *      -- user does not supply attributes for the result lots
   *      -- use parent lot attributes
   *      if( p_parent_lot_attr_tbl.COUNT <> 0 ) then
   *       -- parent lots has attributes
   *         -- derived from the start lot attributes
   *          for i in 1..p_parent_lot_attr_tbl.COUNT LOOP
   *           for j in 1..g_lot_attributes_tbl.COUNT LOOP
   *               if( UPPER(g_lot_attributes_tbl(j).COLUMN_NAME) =
   *                       UPPER(p_parent_lot_attr_tbl(i).COLUMN_NAME) ) then
   *                   g_lot_attributes_Tbl(j).COLUMN_VALUE :=
   *                          p_parent_lot_attr_tbl(i).COLUMN_VALUE;
   *                  end if;
   *                  exit when (UPPER(g_lot_attributes_tbl(j).COLUMN_NAME) =
   *                             UPPER(p_parent_lot_attr_tbl(i).COLUMN_NAME));
   *               end loop;
   *          end loop;
   *      end if;
   *   end if;
   *   -- parent lot does not have attributes and user does not supply attributes
   *   -- for resulting lots.
   *   -- use default lot attributes.
   *   Call inv_lot_sel_attr.get_default to get the default lot attributes
   *
   *   if( l_attributes_default_count > 0 ) then
   *       for i in 1..l_attributes_default_count LOOP
   *           for j in 1..g_lot_attributes_tbl.count LOOP
   *               if( upper(l_attributes_default(i).COLUMN_NAME) =
   *                   upper(g_lot_attributes_tbl(j).COLUMN_NAME) ) then
   *                   g_lot_attributes_tbl(j).COLUMN_VALUE :=
   *                       l_attributes_default(i).COLUMN_VALUE;
   *                   g_lot_attributes_Tbl(j).REQUIRED := l_attributes_default(i).REQUIRED;
   *               end if;
   *               exit when (upper(l_attributes_default(i).COLUMN_NAME) =
   *                             upper(g_lot_attributes_tbl(j).COLUMN_NAME));
   *            end loop;
   *        end loop;
   * end if;
   *
   *  -- Get flexfield
   *  fnd_dflex.get_flexfield('INV', l_attributes_name, v_flexfield, v_flexinfo);
   *
   *  -- Get Contexts
   *  fnd_dflex.get_contexts(v_flexfield, v_contexts);
   *  -- Get Context Value.
   *  if g_lot_attributes_tbl(9).column_value is null then
   *     inv_lot_sel_attr.get_context_code(l_context_value,
   *        p_organization_id,p_inventory_item_id,l_attributes_name);
   *     g_lot_attributes_tbl(9).column_value := l_context_value;
   *  else
   *     l_context_value :=  g_lot_attributes_tbl(9).column_value;
   *  end if;
   *
   *  if l_context_value is not null then
   *     fnd_flex_descval.set_context_value(l_context_value);
   *      fnd_flex_descval.clear_column_values;
   *      fnd_flex_descval.set_column_value('LOT_ATTRIBUTE_CATEGORY',
   *        g_lot_attributes_tbl(9).column_value);
   *          -- Setting the Values for Validating
   *      FOR i IN 1..v_contexts.ncontexts LOOP
   *          IF(v_contexts.is_enabled(i) AND ((UPPER(v_contexts.context_code(i)) =
   *            UPPER(l_context_value)) OR
   *             v_contexts.is_global(i))) THEN
   *  -- Get segments
   *             fnd_dflex.get_segments(fnd_dflex.make_context(v_flexfield,
   *                  v_contexts.context_code(i)), v_segments, TRUE);
   *             <<segmentLoop>>
   *             FOR j IN 1..v_segments.nsegments LOOP
   *                 IF v_segments.is_enabled(j) THEN
   *                    v_colName := v_segments.application_column_name(j);
   *                     <<columnLoop>>
   *                     FOR k IN 1..g_lot_attributes_tbl.count() LOOP
   *                         IF UPPER(v_colName) =
   *                            UPPER(g_lot_attributes_tbl(k).column_name) THEN
   *                             -- Sets the Values for Validation
   *                             -- Setting the column data type for validation
   *                   set the column value to the value in g_lot_attributes
   *                          if segment is required and the column value is NULL then
   *                      return a warning column value required
   *                end if;
   *          EXIT ColumnLoop;
   *                     END LOOP columnLoop;
   *                  END IF;
   *              END LOOP segmentLoop;
   *           END IF;
   *     END LOOP contextLoop;
   *      -- Call the  validating routine for Lot Attributes.
   *         l_status := fnd_flex_descval.validate_desccols(
   *              appl_short_name => 'INV',
   *              desc_flex_name => l_attributes_name);
   *     if l_status = TRUE then
   *        return l_validation_status := 'Y';
   *     else
   *        return l_validation_status := 'N';
   *     end if;
   *  else
   *     -- no context found;
   *     return l_validation_status := 'Y'
   *  end if; -- if l_context_value is not null
   *  x_lot_attr_tbl := g_lot_attributes_tbl;
   *  x_validation_status := l_validation_status;
   *********************************************************************************************/
  PROCEDURE validate_attributes (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , x_validation_status     OUT NOCOPY      VARCHAR2
  , x_lot_attr_tbl          OUT NOCOPY      inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , p_lot_number            IN              VARCHAR2              --parent lot
  , p_organization_id       IN              NUMBER
  , p_inventory_item_id     IN              NUMBER
  , p_parent_lot_attr_tbl   IN              inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , p_result_lot_attr_tbl   IN              inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , p_transaction_type_id   IN              NUMBER
  )
  IS
    l_attributes_name            VARCHAR2 (50)            := 'Lot Attributes';
    v_flexfield                  fnd_dflex.dflex_r;
    v_flexinfo                   fnd_dflex.dflex_dr;
    v_contexts                   fnd_dflex.contexts_dr;
    v_segments                   fnd_dflex.segments_dr;
    l_attributes_default_count   NUMBER;
    l_enabled_attributes         NUMBER;
    l_attributes_default         inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    v_context_value              mtl_flex_context.descriptive_flex_context_code%TYPE;
    v_colname                    VARCHAR2 (50);
    l_context_value              VARCHAR2 (150);
    l_return_status              VARCHAR2 (1);
    l_msg_data                   VARCHAR2 (255);
    l_msg_count                  NUMBER;
    l_validation_status          VARCHAR2 (1);
    l_status                     BOOLEAN;
    l_count                      NUMBER                                  := 0;
    l_rs_lot_attr_category       VARCHAR2 (30);
    l_st_lot_attr_category       VARCHAR2 (30);
    l_debug                      NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- call to see if the lot attributes is enabled for this item/org/category combination
    IF (l_debug = 1)
    THEN
      print_debug ('Validate Attributes', 'Validate_Attributes');
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1)
    THEN
      print_debug ('p_inventory_item_id is ' || p_inventory_item_id
                 , 'Validate_attributes'
                  );
      print_debug ('p_organization_id is ' || p_organization_id
                 , 'Validate_attributes'
                  );
    END IF;

    l_enabled_attributes :=
      inv_lot_sel_attr.is_enabled (p_flex_name             => l_attributes_name
                                 , p_organization_id       => p_organization_id
                                 , p_inventory_item_id     => p_inventory_item_id
                                  );

    IF (l_debug = 1)
    THEN
      print_debug ('l_enabled_attributes is ' || l_enabled_attributes
                 , 'Validate_Attributes'
                  );
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling populateLotAttributes', 'Validate_Attributes');
    END IF;

    -- if we are here, means there are some enabled segment, some can be required.
    populatelotattributes;

    IF (l_debug = 1)
    THEN
      print_debug (   'p_result_lot_attr_tbl.COUNT is '
                   || p_result_lot_attr_tbl.COUNT
                 , 'Validate_Attributes'
                  );
      print_debug (   'p_parent_lot_attr_tbl.COUNT is '
                   || p_parent_lot_attr_tbl.COUNT
                 , 'Validate_Attributes'
                  );
    END IF;

    -- Check to see if the values have been passed for the resultant
    -- lot - else pass the values for the parent lot.
    FOR i IN 1 .. p_result_lot_attr_tbl.COUNT
    LOOP
      IF (p_result_lot_attr_tbl (i).column_value IS NOT NULL)
      THEN
        IF (l_debug = 1)
        THEN
          print_debug (   'Column_NAME is '
                       || p_result_lot_attr_tbl (i).column_name
                     , 'get_lot_attr_record'
                      );
          print_debug (   'Column Value is '
                       || p_result_lot_attr_tbl (i).column_value
                     , 'get_lot_attr_record'
                      );
        END IF;

        l_count := l_count + 1;
      END IF;

      IF (UPPER (p_result_lot_attr_tbl (i).column_name) =
                                                      'LOT_ATTRIBUTE_CATEGORY'
         )
      THEN
        l_rs_lot_attr_category := p_result_lot_attr_tbl (i).column_value;
      --contains what is the attr category for this
      END IF;
    END LOOP;

    IF (l_debug = 1)
    THEN
      print_debug ('Count is : ' || l_count, 'Validate_Attributes');
    END IF;

    IF (l_count > 0)
--means some of the attributes are populated in the result lot which culd habe
    --been either from the MTLI or MLN
    THEN
      FOR i IN 1 .. p_result_lot_attr_tbl.COUNT
      LOOP
        FOR j IN 1 .. g_lot_attributes_tbl.COUNT        --These are from MTLI
        LOOP
          IF (UPPER (g_lot_attributes_tbl (j).column_name) =
                                 UPPER (p_result_lot_attr_tbl (i).column_name)
             )
          THEN
            g_lot_attributes_tbl (j).column_value :=
                                       p_result_lot_attr_tbl (i).column_value;

            IF (l_debug = 1)
            THEN
              print_debug (   g_lot_attributes_tbl (j).column_name
                           || ' '
                           || g_lot_attributes_tbl (j).column_value
                         , 'Validate_Attributes'
                          );
            END IF;
          END IF;

          EXIT WHEN (UPPER (g_lot_attributes_tbl (j).column_name) =
                                 UPPER (p_result_lot_attr_tbl (i).column_name)
                    );
        END LOOP;
      END LOOP;
    --g_lot_attriburtes_tbl now conatins al the lot attributes for the resultant lot
    ELSE
      -- user does not supply attributes for the result lots
      -- use parent lot attributes
      IF (p_parent_lot_attr_tbl.COUNT <> 0)
      THEN
        -- derived from the start lot attributes
        FOR i IN 1 .. p_parent_lot_attr_tbl.COUNT
        LOOP
          FOR j IN 1 .. g_lot_attributes_tbl.COUNT
          LOOP
            IF (UPPER (g_lot_attributes_tbl (j).column_name) =
                                 UPPER (p_parent_lot_attr_tbl (i).column_name)
               )
            THEN
              IF (l_debug = 1)
              THEN
                print_debug (g_lot_attributes_tbl (j).column_name
                           , 'Validate_Attributes'
                            );
              END IF;

              IF (g_lot_attributes_tbl (j).column_value IS NULL)
              THEN
                g_lot_attributes_tbl (j).column_value :=
                                       p_parent_lot_attr_tbl (i).column_value;

                IF (l_debug = 1)
                THEN
                  print_debug (   g_lot_attributes_tbl (j).column_name
                               || ' '
                               || g_lot_attributes_tbl (j).column_value
                             , 'Validate_Attributes'
                              );
                END IF;
              END IF;
            END IF;

            EXIT WHEN (UPPER (g_lot_attributes_tbl (j).column_name) =
                                 UPPER (p_parent_lot_attr_tbl (i).column_name)
                      );
          END LOOP;
        END LOOP;
      END IF;
    END IF;

    -- Check to see if the passed value for the lot attribute context for
    -- the resultant lot is different than the one for the parent lot.
    -- If so, raise an error if it is a lot split or a merge transaction.

    /*** Check to see if the segments are filled in and the context is
        null ****/
    /**** Do not need this check since some of the attributes fill in
    as zero and the count will be more than 1 even if the attributes
    arent filled in
    IF (l_rs_lot_attr_category IS NULL AND l_count > 0)  THEN
       print_debug('Resultant lot category is null',   'Validate_Attributes');
       fnd_message.set_name('INV', 'INV_VALID_CAT');
       fnd_msg_pub.add;
       raise FND_API.G_EXC_ERROR;
    end if;

    ******/
    FOR i IN 1 .. p_parent_lot_attr_tbl.COUNT
    LOOP
      IF (UPPER (p_parent_lot_attr_tbl (i).column_name) =
                                                      'LOT_ATTRIBUTE_CATEGORY'
         )
      THEN
        l_st_lot_attr_category := p_parent_lot_attr_tbl (i).column_value;
      END IF;

      EXIT WHEN (UPPER (p_parent_lot_attr_tbl (i).column_name) =
                                                      'LOT_ATTRIBUTE_CATEGORY'
                );
    END LOOP;

    IF     (   (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
            OR (p_transaction_type_id = inv_globals.g_type_inv_lot_split)
           )
       AND (l_st_lot_attr_category <> l_rs_lot_attr_category)
    THEN
      print_debug (   'Lot categories mismatch: '
                   || l_st_lot_attr_category
                   || ','
                   || l_rs_lot_attr_category
                 , 'Validate_Attributes'
                  );
      fnd_message.set_name ('INV', 'INV_VALID_CAT');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- parent lot does not have attributes.
     -- use default lot attributes.
    IF (l_debug = 1)
    THEN
      print_debug ('Calling inv_lot_sel_attr.get_default'
                 , 'Validate_Attributes'
                  );
    END IF;

    inv_lot_sel_attr.get_default
                    (x_attributes_default           => l_attributes_default
                   , x_attributes_default_count     => l_attributes_default_count
                   , x_return_status                => l_return_status
                   , x_msg_count                    => l_msg_count
                   , x_msg_data                     => x_msg_data
                   , p_table_name                   => 'MTL_LOT_NUMBERS'
                   , p_attributes_name              => 'Lot Attributes'
                   , p_inventory_item_id            => p_inventory_item_id
                   , p_organization_id              => p_organization_id
                   , p_lot_serial_number            => p_lot_number
                   , p_attributes                   => g_lot_attributes_tbl
                    );

    IF (l_return_status <> fnd_api.g_ret_sts_success)
    THEN
      x_validation_status := 'N';
      x_return_status := l_return_status;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug (   'l_attributes_default_count is '
                   || l_attributes_default_count
                 , 'Validate_Attributes'
                  );
    END IF;

    IF (l_attributes_default_count > 0)
    THEN
      FOR i IN 1 .. l_attributes_default_count
      LOOP
        FOR j IN 1 .. g_lot_attributes_tbl.COUNT
        LOOP
          IF (    UPPER (l_attributes_default (i).column_name) =
                                  UPPER (g_lot_attributes_tbl (j).column_name)
              AND l_attributes_default (i).column_value IS NOT NULL
             )
          THEN
            IF (l_debug = 1)
            THEN
              print_debug (   'g_lot_attributes_tbl(j).COLUMN_VALUE is '
                           || g_lot_attributes_tbl (j).column_value
                         , 'Validate_attributes'
                          );
              print_debug (   'l_attributes_default(i).COLUMN_VALUE is '
                           || l_attributes_default (i).column_value
                         , 'Validate_attributes'
                          );
            END IF;

            IF (g_lot_attributes_tbl (j).column_value IS NULL)
            THEN
              g_lot_attributes_tbl (j).column_value :=
                                        l_attributes_default (i).column_value;
            END IF;

            g_lot_attributes_tbl (j).required :=
                                             l_attributes_default (i).required;

            IF (l_debug = 1)
            THEN
              print_debug (   'g_lot_attributes_tbl(j).COLUMN_VALUE is '
                           || g_lot_attributes_tbl (j).column_value
                         , 'Validate_attributes'
                          );
            END IF;
          END IF;

          EXIT WHEN (UPPER (l_attributes_default (i).column_name) =
                                  UPPER (g_lot_attributes_tbl (j).column_name)
                    );
        END LOOP;
      END LOOP;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling fnd_dflex.get_flexfield', 'Validate_Attributes');
    END IF;

    -- Get flexfield
    fnd_dflex.get_flexfield ('INV', l_attributes_name, v_flexfield
                           , v_flexinfo);

    IF (l_debug = 1)
    THEN
      print_debug ('calling fnd_dflex.get_context', 'Validate_Attributes');
    END IF;

    -- Get Contexts
    l_context_value := NULL;
    fnd_dflex.get_contexts (v_flexfield, v_contexts);

    --will get the number of contexts, their name etc

    --till now we have populated the attributes in the g_lot_attributes table...now we
    --need to validate these values

    --loop to get the context value for the context lot_attribute_category and poplate
    --the right column in g_lot_attributes table
    FOR i IN 1 .. g_lot_attributes_tbl.COUNT
    LOOP
      IF (    UPPER (g_lot_attributes_tbl (i).column_name) =
                                                      'LOT_ATTRIBUTE_CATEGORY'
          AND g_lot_attributes_tbl (i).column_value IS NULL
         )
      THEN
        inv_lot_sel_attr.get_context_code (l_context_value
                                         , p_organization_id
                                         , p_inventory_item_id
                                         , l_attributes_name
                                          );
        g_lot_attributes_tbl (i).column_value := l_context_value;
      ELSE
        l_context_value := g_lot_attributes_tbl (i).column_value;
      END IF;

      EXIT WHEN (UPPER (g_lot_attributes_tbl (i).column_name) =
                                                      'LOT_ATTRIBUTE_CATEGORY'
                );
    END LOOP;

    IF (l_debug = 1)
    THEN
      print_debug ('l_context_value is ' || l_context_value
                 , 'Validate_Attributes'
                  );
    END IF;

    /* 2725380 */
    IF ((l_enabled_attributes = 0) AND (l_context_value IS NULL))
    THEN
      -- return no lot attributes segment is enabled
      IF (l_debug = 1)
      THEN
        print_debug ('l_context is null , attr enabaled = 0'
                   , 'Validate_Attributes'
                    );
      END IF;

      x_validation_status := 'Y';
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_count := 0;
      x_msg_data := NULL;
      --x_lot_attr_tbl := p_result_lot_attr_tbl;
      RETURN;
    END IF;

    IF l_context_value IS NOT NULL
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('calling fnd_flex_descval.set_context_value'
                   , 'Validate_Attributes'
                    );
      END IF;

      fnd_flex_descval.set_context_value (l_context_value);

      IF (l_debug = 1)
      THEN
        print_debug ('calling fnd_flex_descval.clear_column_values'
                   , 'Validate_Attributes'
                    );
      END IF;

      fnd_flex_descval.clear_column_values;

      IF (l_debug = 1)
      THEN
        print_debug
          (   'calling fnd_flex_descval.clear_column_values LOT_ATTRIBUTE_CATEGORY = '
           || l_context_value
         , 'Validate_Attributes'
          );
      END IF;

      fnd_flex_descval.set_column_value ('LOT_ATTRIBUTE_CATEGORY'
                                       , l_context_value
                                        );

      -- Setting the Values for Validating
      IF (l_debug = 1)
      THEN
        print_debug (   'g_lot_attributes_tbl.COUNT is '
                     || g_lot_attributes_tbl.COUNT
                   , 'Validate_Attributes'
                    );
      END IF;

      FOR i IN 1 .. v_contexts.ncontexts
      LOOP
        IF (    v_contexts.is_enabled (i)
            AND (   (UPPER (v_contexts.context_code (i)) =
                                                       UPPER (l_context_value)
                    )
                 OR v_contexts.is_global (i)
                )
           )
        THEN
          --get the segments that have been enabled for this context
          -- Get segments
          IF (l_debug = 1)
          THEN
            print_debug ('calling fnd_dflex.get_segments'
                       , 'Validate_Attributes'
                        );
          END IF;
          fnd_dflex.get_segments
                          (fnd_dflex.make_context (v_flexfield
                                                 , v_contexts.context_code (i)
                                                  )
                         , v_segments
                         , TRUE
                          );

          <<segmentloop>>
          FOR j IN 1 .. v_segments.nsegments
          LOOP
            IF v_segments.is_enabled (j)
            THEN
              v_colname := v_segments.application_column_name (j);

              IF (l_debug = 1)
              THEN
                print_debug ('v_colName is ' || v_colname
                           , 'Validate_Attributes'
                            );
              END IF;

              <<columnloop>>
              FOR k IN 1 .. g_lot_attributes_tbl.COUNT
              LOOP
                IF UPPER (v_colname) =
                                 UPPER (g_lot_attributes_tbl (k).column_name)
                THEN
                  IF (l_debug = 1)
                  THEN
                    print_debug (g_lot_attributes_tbl (k).column_name
                               , 'Validate_attributes'
                                );
                  END IF;

                  -- Sets the Values for Validation
                  -- Setting the column data type for validation
                  IF g_lot_attributes_tbl (k).column_type = 'DATE'
                  THEN
                    IF (l_debug = 1)
                    THEN
                      print_debug (   'set_column_value '
                                   || g_lot_attributes_tbl (k).column_value
                                 , 'Validate_Attributes'
                                  );
                    END IF;

                    fnd_flex_descval.set_column_value
                      (g_lot_attributes_tbl (k).column_name
                     , fnd_date.canonical_to_date
                                         (g_lot_attributes_tbl (k).column_value
                                         )
                      );
                  END IF;

                  IF g_lot_attributes_tbl (k).column_type = 'NUMBER'
                  THEN
                    IF (l_debug = 1)
                    THEN
                      print_debug (   'set_column_value '
                                   || g_lot_attributes_tbl (k).column_value
                                 , 'Validate_Attributes'
                                  );
                    END IF;

                    fnd_flex_descval.set_column_value
                              (g_lot_attributes_tbl (k).column_name
                             , TO_NUMBER (g_lot_attributes_tbl (k).column_value
                                         )
                              );
                  END IF;

                  IF g_lot_attributes_tbl (k).column_type = 'VARCHAR2'
                  THEN
                    IF (l_debug = 1)
                    THEN
                      print_debug (   'set_column_value '
                                   || g_lot_attributes_tbl (k).column_value
                                 , 'Validate_Attributes'
                                  );
                    END IF;

                    fnd_flex_descval.set_column_value
                                         (g_lot_attributes_tbl (k).column_name
                                        , g_lot_attributes_tbl (k).column_value
                                         );
                  END IF;

                  IF (v_segments.is_required (j))
                  THEN
                    IF (g_lot_attributes_tbl (k).column_value IS NULL)
                    THEN
                      IF (l_debug = 1)
                      THEN
                        print_debug (   g_lot_attributes_tbl (k).column_name
                                     || ' '
                                     || g_lot_attributes_tbl (k).column_value
                                   , 'Validate_Attributes'
                                    );
                      END IF;

                      fnd_message.set_name ('INV'
                                          , 'INV_LOT_SEL_DEFAULT_REQUIRED'
                                           );
                      fnd_message.set_token ('ATTRNAME', l_attributes_name);
                      fnd_message.set_token ('CONTEXTCODE'
                                           , v_contexts.context_code (i)
                                            );
                      fnd_message.set_token
                                        ('SEGMENT'
                                       , v_segments.application_column_name
                                                                           (j)
                                        );
                      fnd_msg_pub.ADD;
                    END IF;
                  END IF;
                END IF;

                EXIT WHEN (UPPER (v_colname) =
                                  UPPER (g_lot_attributes_tbl (k).column_name)
                          );
              END LOOP;
            END IF;
          END LOOP;
        END IF;
      END LOOP;

      --now all the values have been set for the global variables
      -- Call the  validating routine for Lot Attributes.
      IF (l_debug = 1)
      THEN
        print_debug ('calling fnd_flex_descval.validate_desccols'
                   , 'Validate_Attributes'
                    );
      END IF;

      l_status :=
        fnd_flex_descval.validate_desccols
                                          (appl_short_name     => 'INV'
                                         , desc_flex_name      => l_attributes_name
                                          );

      IF l_status = TRUE
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('l_status is true', 'Validate_Attributes');
        END IF;

        l_validation_status := 'Y';
      ELSE
        IF (l_debug = 1)
        THEN
          print_debug ('l_status is false', 'Validate_Attributes');
        END IF;

        l_validation_status := 'N';
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data := fnd_flex_descval.error_message;
        fnd_message.set_name ('INV', 'GENERIC');
        fnd_message.set_token ('MSGBODY', x_msg_data);
        fnd_msg_pub.ADD;
        x_msg_count := NVL (x_msg_count, 0) + 1;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      -- no context found;
      l_validation_status := 'Y';
      x_return_status := fnd_api.g_ret_sts_success;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    END IF;                                  -- if l_context_value is not null

    x_lot_attr_tbl := g_lot_attributes_tbl;
    x_validation_status := l_validation_status;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Attributes');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_attributes;

  /*********************************************************************************
   *Added for OSFM support to Serialized Lot Items. Populates the                  *
   *g_lot_ser_attributes_tbl with the attribute columns present in the mtl_serial_ *
   *numbers_interface                                                              *
   *********************************************************************************/
  PROCEDURE populate_serial_attributes
  IS
    CURSOR column_csr (p_table_name VARCHAR2, p_owner VARCHAR2)
    IS
      SELECT   column_name
             , data_type
          FROM all_tab_columns
         WHERE table_name = p_table_name AND owner = p_owner
               /*Bug:4724150. Commented the following condition 1 as the attribute
                 columns becomes out of range of 20 to 91 when some extraneous attributes are added*/
               --AND column_id BETWEEN 20 AND 91
      ORDER BY column_id;

    l_column_idx      BINARY_INTEGER := 0;
    l_ret             BOOLEAN;
    l_status          VARCHAR2 (1);
    l_industry        VARCHAR2 (1);
    l_oracle_schema   VARCHAR2 (30);
    l_debug           NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1)
    THEN
      print_debug ('IN populate_serial_attributes'
                 , 'populate_serial_Attributes'
                  );
    END IF;

    l_ret :=
      fnd_installation.get_app_info ('INV'
                                   , l_status
                                   , l_industry
                                   , l_oracle_schema
                                    );

    FOR l_column_csr IN column_csr ('MTL_SERIAL_NUMBERS_INTERFACE'
                                  , l_oracle_schema
                                   )
    LOOP
      l_column_idx := l_column_idx + 1;
      g_lot_ser_attributes_tbl (l_column_idx).column_name :=
                                                     l_column_csr.column_name;
      g_lot_ser_attributes_tbl (l_column_idx).column_type :=
                                                       l_column_csr.data_type;
    END LOOP;

    IF (l_debug = 1)
    THEN
      print_debug ('Done with populate_serial_attributes'
                 , 'populate_serial_Attributes'
                  );
    END IF;
  END;


  /*********************************************************************************
   *Added for OSFM support to Serialized Lot Items.                                *
   *Validates the resulting serials attributes. If the attributes are not present  *
   *for the resulting serials then the default serial attributes are taken         *
   *These attributes are then validated using the descriptive flexfield validation *
   *APIs                                                                           *
   *********************************************************************************/
  PROCEDURE validate_serial_attributes (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY      NUMBER
  , x_msg_data              OUT NOCOPY      VARCHAR2
  , x_validation_status     OUT NOCOPY      VARCHAR2
  , x_ser_attr_tbl          OUT NOCOPY      inv_lot_sel_attr.lot_sel_attributes_tbl_type
  , p_ser_number            IN              VARCHAR2
  , p_organization_id       IN              NUMBER
  , p_inventory_item_id     IN              NUMBER
  , p_result_ser_attr_tbl   IN              inv_lot_sel_attr.lot_sel_attributes_tbl_type
  )
  IS
    l_attributes_name            VARCHAR2 (50)         := 'Serial Attributes';
    v_flexfield                  fnd_dflex.dflex_r;
    v_flexinfo                   fnd_dflex.dflex_dr;
    v_contexts                   fnd_dflex.contexts_dr;
    v_segments                   fnd_dflex.segments_dr;
    l_attributes_default_count   NUMBER;
    l_enabled_attributes         NUMBER;
    l_attributes_default         inv_lot_sel_attr.lot_sel_attributes_tbl_type;
    v_context_value              mtl_flex_context.descriptive_flex_context_code%TYPE;
    v_colname                    VARCHAR2 (50);
    l_context_value              VARCHAR2 (150);
    l_return_status              VARCHAR2 (1);
    l_msg_data                   VARCHAR2 (255);
    l_msg_count                  NUMBER;
    l_validation_status          VARCHAR2 (1);
    l_status                     BOOLEAN;
    l_count                      NUMBER                                  := 0;
    l_rs_ser_attr_category       VARCHAR2 (30);
    l_st_ser_attr_category       VARCHAR2 (30);
    l_debug                      NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- call to see if the serial attributes is enabled for this item/org/category combination
    IF (l_debug = 1)
    THEN
      print_debug ('In Validate_serial_Attributes'
                 , 'Validate_serial_Attributes'
                  );
    END IF;

    l_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    l_enabled_attributes :=
      inv_lot_sel_attr.is_enabled (p_flex_name             => l_attributes_name
                                 , p_organization_id       => p_organization_id
                                 , p_inventory_item_id     => p_inventory_item_id
                                  );

    -- if we are here, means there are some enabled segment, some can be required.
    IF (l_debug = 1)
    THEN
      print_debug ('calling populate_serila_attributes'
                 , 'validate_serial_attributes'
                  );
    END IF;

    populate_serial_attributes;

    -- Check to see if the values have been passed for the resultant
    -- serials - else pass the values for the parent serial.
    FOR i IN 1 .. p_result_ser_attr_tbl.COUNT
    LOOP
      IF (p_result_ser_attr_tbl (i).column_value IS NOT NULL)
      THEN
        IF (l_debug = 1)
        THEN
          print_debug (   'Column_NAME is '
                       || p_result_ser_attr_tbl (i).column_name
                     , 'validate_serial_attributes'
                      );
          print_debug (   'Column Value is '
                       || p_result_ser_attr_tbl (i).column_value
                     , 'validate_serial_attributes'
                      );
        END IF;

        l_count := l_count + 1;
      END IF;

      IF (UPPER (p_result_ser_attr_tbl (i).column_name) =
                                                   'SERIAL_ATTRIBUTE_CATEGORY'
         )
      THEN
        l_rs_ser_attr_category := p_result_ser_attr_tbl (i).column_value;
      --contains what is the attr category for this
      END IF;
    END LOOP;

    IF (l_count > 0)
    THEN
      FOR i IN 1 .. p_result_ser_attr_tbl.COUNT
      LOOP
        FOR j IN 1 .. g_lot_ser_attributes_tbl.COUNT
        LOOP
          IF (UPPER (g_lot_ser_attributes_tbl (j).column_name) =
                                 UPPER (p_result_ser_attr_tbl (i).column_name)
             )
          THEN
            g_lot_ser_attributes_tbl (j).column_value :=
                                       p_result_ser_attr_tbl (i).column_value;
          END IF;

          EXIT WHEN (UPPER (g_lot_ser_attributes_tbl (j).column_name) =
                                 UPPER (p_result_ser_attr_tbl (i).column_name)
                    );
        END LOOP;
      END LOOP;
    --for serials we do not care abt the parent serials
    END IF;



    /*Removing the check to see if the parent serial attribute category meets
      child serial attribute category becoz we are not copying from parent
    */


     -- use default serial attributes.
    BEGIN
      inv_lot_sel_attr.get_default
                   (x_attributes_default           => l_attributes_default
                  , x_attributes_default_count     => l_attributes_default_count
                  , x_return_status                => x_return_status
                  , x_msg_count                    => x_msg_count
                  , x_msg_data                     => x_msg_data
                  , p_table_name                   => 'MTL_SERIAL_NUMBERS'
                  , p_attributes_name              => 'Serial Attributes'
                  , p_inventory_item_id            => p_inventory_item_id
                  , p_organization_id              => p_organization_id
                  , p_lot_serial_number            => p_ser_number
                  , p_attributes                   => g_lot_ser_attributes_tbl
                   );
    EXCEPTION
      WHEN OTHERS
      THEN
        l_validation_status := 'N';
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    IF (x_return_status <> fnd_api.g_ret_sts_success)
    THEN
      l_validation_status := 'N';
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_attributes_default_count > 0)
    THEN
      FOR i IN 1 .. l_attributes_default_count
      LOOP
        FOR j IN 1 .. g_lot_ser_attributes_tbl.COUNT
        LOOP
          IF (    UPPER (l_attributes_default (i).column_name) =
                              UPPER (g_lot_ser_attributes_tbl (j).column_name)
              AND l_attributes_default (i).column_value IS NOT NULL
             )
          THEN
            IF (l_debug = 1)
            THEN
              print_debug (   'g_lot_ser_attributes_tbl(j).COLUMN_VALUE is '
                           || g_lot_ser_attributes_tbl (j).column_value
                         , 'validate_serial_attributes'
                          );
              print_debug (   'l_attributes_default(i).COLUMN_VALUE is '
                           || l_attributes_default (i).column_value
                         , 'validate_serial_attributes'
                          );
            END IF;

            IF (g_lot_ser_attributes_tbl (j).column_value IS NULL)
            THEN
              g_lot_ser_attributes_tbl (j).column_value :=
                                        l_attributes_default (i).column_value;
            END IF;

            g_lot_ser_attributes_tbl (j).required :=
                                             l_attributes_default (i).required;

            IF (l_debug = 1)
            THEN
              print_debug (   'g_lot_ser_attributes_tbl(j).COLUMN_VALUE is '
                           || g_lot_ser_attributes_tbl (j).column_value
                         , 'validate_serial_attributes'
                          );
            END IF;
          END IF;

          EXIT WHEN (UPPER (l_attributes_default (i).column_name) =
                              UPPER (g_lot_ser_attributes_tbl (j).column_name)
                    );
        END LOOP;
      END LOOP;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('calling fnd_dflex.get_flexfield'
                 , 'validate_serial_attributes'
                  );
    END IF;

    -- Get flexfield
    fnd_dflex.get_flexfield ('INV', l_attributes_name, v_flexfield
                           , v_flexinfo);

    IF (l_debug = 1)
    THEN
      print_debug ('calling fnd_dflex.get_context'
                 , 'validate_serial_attributes'
                  );
    END IF;

    -- Get Contexts
    l_context_value := NULL;
    fnd_dflex.get_contexts (v_flexfield, v_contexts);

    --will get the number of contexts, their name etc

    --till now we have populated the attributes in the g_lot_attributes table...now we
    --need to validate these values

    --loop to get the context value for the context lot_attribute_category and poplate
    --the right column in g_lot_attributes table
    FOR i IN 1 .. g_lot_ser_attributes_tbl.COUNT
    LOOP
      IF (    UPPER (g_lot_ser_attributes_tbl (i).column_name) =
                                                   'SERIAL_ATTRIBUTE_CATEGORY'
          AND g_lot_ser_attributes_tbl (i).column_value IS NULL
         )
      THEN
        inv_lot_sel_attr.get_context_code (l_context_value
                                         , p_organization_id
                                         , p_inventory_item_id
                                         , l_attributes_name
                                          );
        g_lot_ser_attributes_tbl (i).column_value := l_context_value;
      ELSE
        l_context_value := g_lot_ser_attributes_tbl (i).column_value;
      END IF;

      EXIT WHEN (UPPER (g_lot_ser_attributes_tbl (i).column_name) =
                                                   'SERIAL_ATTRIBUTE_CATEGORY'
                );
    END LOOP;

    IF (l_debug = 1)
    THEN
      print_debug ('l_context_value is ' || l_context_value
                 , 'validate_serial_attributes'
                  );
    END IF;

    IF ((l_enabled_attributes = 0) AND (l_context_value IS NULL))
    THEN
      -- return no lot attributes segment is enabled
      IF (l_debug = 1)
      THEN
        print_debug ('l_context is null , attr enabaled = 0'
                   , 'validate_serial_attributes'
                    );
      END IF;

      x_validation_status := 'Y';
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_count := 0;
      x_msg_data := NULL;
      x_ser_attr_tbl := g_lot_ser_attributes_tbl;
      RETURN;
    END IF;

    IF l_context_value IS NOT NULL
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('calling fnd_flex_descval.set_context_value'
                   , 'validate_serial_attributes'
                    );
      END IF;

      fnd_flex_descval.set_context_value (l_context_value);

      IF (l_debug = 1)
      THEN
        print_debug ('calling fnd_flex_descval.clear_column_values'
                   , 'validate_serial_attributes'
                    );
      END IF;

      fnd_flex_descval.clear_column_values;

      IF (l_debug = 1)
      THEN
        print_debug
          (   'calling fnd_flex_descval.clear_column_values SERIAL_ATTRIBUTE_CATEGORY = '
           || l_context_value
         , 'validate_serial_attributes'
          );
      END IF;

      fnd_flex_descval.set_column_value ('SERIAL_ATTRIBUTE_CATEGORY'
                                       , l_context_value
                                        );

      -- Setting the Values for Validating
      IF (l_debug = 1)
      THEN
        print_debug (   'g_lot_ser_attributes_tbl.COUNT is '
                     || g_lot_ser_attributes_tbl.COUNT
                   , 'validate_serial_attributes'
                    );
      END IF;

      /*contenets of the v_contexts : -
          (ncontexts          BINARY_INTEGER,
          global_context      BINARY_INTEGER,
          context_code        context_code_a,
          context_name        context_name_a,
          context_description context_description_a,
          is_enabled          boolean_a,
          is_global           boolean_a)
      */
      FOR i IN 1 .. v_contexts.ncontexts
      LOOP
        IF (    v_contexts.is_enabled (i)
            AND (   (UPPER (v_contexts.context_code (i)) =
                                                       UPPER (l_context_value)
                    )
                 OR v_contexts.is_global (i)
                )
           )
        THEN
          --get the segments that have been enabled for this context
          -- Get segments
          IF (l_debug = 1)
          THEN
            print_debug ('calling fnd_dflex.get_segments'
                       , 'validate_serial_attributes'
                        );
          END IF;

          /* v_segmenst contains following :-
          (nsegments           BINARY_INTEGER,
          application_column_name application_column_name_a,
          segment_name        segment_name_a,
          sequence            sequence_a,
          is_displayed        boolean_a,
          display_size        display_size_a,
          row_prompt          row_prompt_a,
          column_prompt       column_prompt_a,
          is_enabled          boolean_a,
          is_required         boolean_a,
          description         segment_description_a,
          value_set           value_set_a,
          default_type        default_type_a,
          default_value       default_value_a)
          */
          fnd_dflex.get_segments
                          (fnd_dflex.make_context (v_flexfield
                                                 , v_contexts.context_code (i)
                                                  )
                         , v_segments
                         , TRUE
                          );

          <<segmentloop>>
          FOR j IN 1 .. v_segments.nsegments
          LOOP
            IF v_segments.is_enabled (j)
            THEN
              v_colname := v_segments.application_column_name (j);

              IF (l_debug = 1)
              THEN
                print_debug ('v_colName is ' || v_colname
                           , 'validate_serial_attributes'
                            );
              END IF;

              <<columnloop>>
              FOR k IN 1 .. g_lot_ser_attributes_tbl.COUNT
              LOOP
                IF UPPER (v_colname) =
                             UPPER (g_lot_ser_attributes_tbl (k).column_name)
                THEN
                  IF (l_debug = 1)
                  THEN
                    print_debug (g_lot_ser_attributes_tbl (k).column_name
                               , 'validate_serial_attributes'
                                );
                  END IF;

                  -- Sets the Values for Validation
                  -- Setting the column data type for validation
                  IF g_lot_ser_attributes_tbl (k).column_type = 'DATE'
                  THEN
                    IF (l_debug = 1)
                    THEN
                      print_debug (   'set_column_value '
                                   || g_lot_ser_attributes_tbl (k).column_value
                                 , 'validate_serial_attributes'
                                  );
                    END IF;

                    fnd_flex_descval.set_column_value
                      (g_lot_ser_attributes_tbl (k).column_name
                     , fnd_date.canonical_to_date
                                     (g_lot_ser_attributes_tbl (k).column_value
                                     )
                      );
                  END IF;

                  IF g_lot_ser_attributes_tbl (k).column_type = 'NUMBER'
                  THEN
                    IF (l_debug = 1)
                    THEN
                      print_debug (   'set_column_value '
                                   || g_lot_ser_attributes_tbl (k).column_value
                                 , 'validate_serial_attributes'
                                  );
                    END IF;

                    fnd_flex_descval.set_column_value
                          (g_lot_ser_attributes_tbl (k).column_name
                         , TO_NUMBER (g_lot_ser_attributes_tbl (k).column_value
                                     )
                          );
                  END IF;

                  IF g_lot_ser_attributes_tbl (k).column_type = 'VARCHAR2'
                  THEN
                    IF (l_debug = 1)
                    THEN
                      print_debug (   'set_column_value '
                                   || g_lot_ser_attributes_tbl (k).column_value
                                 , 'validate_serial_attributes'
                                  );
                    END IF;

                    fnd_flex_descval.set_column_value
                                     (g_lot_ser_attributes_tbl (k).column_name
                                    , g_lot_ser_attributes_tbl (k).column_value
                                     );
                  END IF;

                  IF (v_segments.is_required (j))
                  THEN
                    IF (g_lot_ser_attributes_tbl (k).column_value IS NULL)
                    THEN
                      IF (l_debug = 1)
                      THEN
                        print_debug
                                 (   g_lot_ser_attributes_tbl (k).column_name
                                  || ' '
                                  || g_lot_ser_attributes_tbl (k).column_value
                                , 'validate_serial_attributes'
                                 );
                      END IF;

                      fnd_message.set_name ('INV'
                                          , 'INV_LOT_SEL_DEFAULT_REQUIRED'
                                           );
                      fnd_message.set_token ('ATTRNAME', l_attributes_name);
                      fnd_message.set_token ('CONTEXTCODE'
                                           , v_contexts.context_code (i)
                                            );
                      fnd_message.set_token
                                        ('SEGMENT'
                                       , v_segments.application_column_name
                                                                           (j)
                                        );
                      fnd_msg_pub.ADD;
                    END IF;
                  END IF;
                END IF;

                EXIT WHEN (UPPER (v_colname) =
                              UPPER (g_lot_ser_attributes_tbl (k).column_name)
                          );
              END LOOP;
            END IF;
          END LOOP;
        END IF;
      END LOOP;

      --now all the values have been set for the global variables
      -- Call the  validating routine for Lot Attributes.
      IF (l_debug = 1)
      THEN
        print_debug ('calling fnd_flex_descval.validate_desccols'
                   , 'validate_serial_attributes'
                    );
      END IF;

      l_status :=
        fnd_flex_descval.validate_desccols
                                          (appl_short_name     => 'INV'
                                         , desc_flex_name      => l_attributes_name
                                          );

      IF l_status = TRUE
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('l_status is true', 'validate_serial_attributes');
        END IF;

        l_validation_status := 'Y';
      ELSE
        IF (l_debug = 1)
        THEN
          print_debug ('l_status is false', 'validate_serial_attributes');
        END IF;

        l_validation_status := 'N';
        x_return_status := fnd_api.g_ret_sts_error;
        x_msg_data := fnd_flex_descval.error_message;
        fnd_message.set_name ('INV', 'GENERIC');
        fnd_message.set_token ('MSGBODY', x_msg_data);
        fnd_msg_pub.ADD;
        x_msg_count := NVL (x_msg_count, 0) + 1;
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      -- no context found;
      l_validation_status := 'Y';
      x_return_status := fnd_api.g_ret_sts_success;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    END IF;                                  -- if l_context_value is not null

    x_ser_attr_tbl := g_lot_ser_attributes_tbl;
    x_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_validation_status := 'E';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'validate_serial_attributes');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_serial_attributes;

  /*********************************************************************************************
   * Pseudo-code:                          *
   *   l_organization_id := p_st_org_id_tbl(1);
   *   l_inventory_item_id  := p_st_item_id_tbl(1);
   *   l_subinventory_code := p_St_sub_code_tbl(1);
   *   l_locator_id := p_st_loc_id_tbl(1);
   *   l_lot_number := p_st_lot_num_tbl(1);
   *   l_cost_group_id := p_st_cost_group_tbl(1);
   *   l_lpn_id := p_st_lpn_id_tbl(1);
   *   l_revision := p_st_revision_tbl(1);
   *
   *   if( l_lpn_id IS NULL ) then
   *       l_containerized_flag := 2;
   *   else
   *       l_containerized_flag := 1;
   *   end if;
   *
   *   get cost group by calling inv_cost_group_update.proc_get_costgroup;
   *
   *   if( no cost groups is stamped for the resulting lots  ) then
   *        assign the parent lot cost groups to the resulting lots
   *        return validation status = 'Y'
   *   else
   *      for each resulting lots cost group LOOP
   *          if resulting lot cost group <> parent lot cost group then
   *                assign the parent lot cost group to the resulting lot cost group
   *            end if
   *      end loop;
   *      return l_validation_status := 'Y';
   *    end if;
   *   if( transactions is lot merge ) then
   *   for i in 2..l_start_count LOOP
   *       l_organization_id := p_st_org_id_tbl(i);
   *       l_inventory_item_id  := p_st_item_id_tbl(i);
   *       l_subinventory_code := p_St_sub_code_tbl(i);
   *       l_locator_id := p_st_loc_id_tbl(i);
   *       l_lot_number := p_st_lot_num_tbl(i);
   *       l_current_cost_group_id := p_st_cost_group_tbl(i);
   *       l_lpn_id := p_st_lpn_id_tbl(i);
   *       l_revision := p_st_revision_tbl(i);
   *       if( l_current_cost_group_id IS NULL OR l_current_cost_group_id = -1) then
   *           -- get cost group for the parent lot
   *        if( l_lpn_id IS NULL ) then
   *            l_containerized_flag := 2;
   *        else
   *            l_containerized_flag := 1;
   *        end if;
   *
   *   call INV_COST_GROUP_UPDATE.PROC_GET_COSTGROUP to get cost group
   *     end if;
   *     if( l_current_cost_group_id <> l_cost_group_id ) THEN
   *   return error different cost group for lot merge error
   *      end if;
   *
   *  END LOOP;
   *  if( number of resulting lots  > 1 ) then
   *   return too many resulting lots error
   *  end if;
   *
   *  elsif( transaction is lot translate ) then
   *    -- do not assign cost group if the lot changed item.
   *    if( no of starting lot  > 1 OR no of resulting lot  > 1 ) then
   *    return too many start lot and result lot error
   *    end if;
   *
   *    if( the item is changed ) then
   *     --do nothing. let the trx manager assign the cost group;
   *       return validation status = 'Y'
   *    end if;
   *  end if;
   *************************************************************************************************/
  PROCEDURE validate_cost_groups (
    x_rs_cost_group_tbl       IN OUT NOCOPY   number_table
  , x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , x_validation_status       OUT NOCOPY      VARCHAR2
  , p_transaction_type_id     IN              NUMBER
  , p_transaction_action_id   IN              NUMBER
  , p_st_org_id_tbl           IN              number_table
  , p_st_item_id_tbl          IN              number_table
  , p_st_sub_code_tbl         IN              sub_code_table
  , p_st_loc_id_tbl           IN              number_table
  , p_st_lot_num_tbl          IN              lot_number_table
  , p_st_cost_group_tbl       IN              number_table
  , p_st_revision_tbl         IN              revision_table
  , p_st_lpn_id_tbl           IN              number_table
  , p_rs_org_id_tbl           IN              number_table
  , p_rs_item_id_tbl          IN              number_table
  , p_rs_sub_code_tbl         IN              sub_code_table
  , p_rs_loc_id_tbl           IN              number_table
  , p_rs_lot_num_tbl          IN              lot_number_table
  , p_rs_revision_tbl         IN              revision_table
  , p_rs_lpn_id_tbl           IN              number_table
  )
  IS
    l_validation_status       VARCHAR2 (1);
    l_start_count             NUMBER;
    l_result_count            NUMBER;
    l_organization_id         NUMBER;
    l_inventory_item_id       NUMBER;
    l_subinventory_code       VARCHAR2 (30);
    l_lot_number              VARCHAR2 (30);
    l_cost_group_id           NUMBER;
    l_current_cost_group_id   NUMBER;
    l_result_cost_group_id    NUMBER;
    l_locator_id              NUMBER;
    l_lpn_id                  NUMBER;
    l_revision                VARCHAR2 (30);
    l_containerized_flag      NUMBER;
    l_return_status           VARCHAR2 (1);
    v_cost_group_id           NUMBER;
    l_debug                   NUMBER
                            := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- assign return value first
    IF (l_debug = 1)
    THEN
      print_debug ('in validate cost group', 'Validate_Cost_Group');
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    l_start_count := p_st_lot_num_tbl.COUNT;
    l_result_count := p_rs_lot_num_tbl.COUNT;

    IF (l_debug = 1)
    THEN
      print_debug ('l_start_count is ' || l_start_count
                 , 'Validate_Cost_Group'
                  );
      print_debug ('l_result_count is ' || l_result_count
                 , 'Validate_Cost_Group'
                  );
    END IF;

    l_organization_id := p_st_org_id_tbl (1);
    l_inventory_item_id := p_st_item_id_tbl (1);
    l_subinventory_code := p_st_sub_code_tbl (1);
    l_locator_id := p_st_loc_id_tbl (1);
    l_lot_number := p_st_lot_num_tbl (1);
    l_cost_group_id := p_st_cost_group_tbl (1);
    l_lpn_id := p_st_lpn_id_tbl (1);
    l_revision := p_st_revision_tbl (1);

    IF (l_debug = 1)
    THEN
      print_debug ('l_organization_id is ' || l_organization_id
                 , 'Validate_Cost_Group'
                  );
      print_debug ('l_inventory_item_id is ' || l_inventory_item_id
                 , 'Validate_Cost_Group'
                  );
      print_debug ('l_subinventory_code is ' || l_subinventory_code
                 , 'Validate_Cost_Group'
                  );
      print_debug ('l_locator_id is ' || l_locator_id, 'Validate_Cost_Group');
      print_debug ('l_lot_number is ' || l_lot_number, 'Validate_Cost_Group');
      print_debug ('l_cost_group_id is ' || l_cost_group_id
                 , 'Validate_Cost_Group'
                  );
      print_debug ('l_lpn_id is ' || l_lpn_id, 'Validate_Cost_Group');
      print_debug ('l_revision is ' || l_revision, 'Validate_Cost_Group');
    END IF;

    --if( l_cost_group_id IS NULL or l_cost_group_id = -1 ) then
         -- get cost group for the parent lot
    IF (l_lpn_id IS NULL)
    THEN
      l_containerized_flag := 2;
    ELSE
      l_containerized_flag := 1;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('l_containerized_flag is ' || l_containerized_flag
                 , 'Validate_Cost_Group'
                  );
      print_debug ('calling inv_cost_group_update.proc_get_costgroup'
                 , 'Validate_Cost_Group'
                  );
    END IF;

    inv_cost_group_update.proc_get_costgroup
                          (p_organization_id           => l_organization_id
                         , p_inventory_item_id         => l_inventory_item_id
                         , p_subinventory_code         => l_subinventory_code
                         , p_locator_id                => l_locator_id
                         , p_revision                  => l_revision
                         , p_lot_number                => l_lot_number
                         , p_serial_number             => NULL
                         , p_containerized_flag        => l_containerized_flag
                         , p_lpn_id                    => l_lpn_id
                         , p_transaction_action_id     => p_transaction_action_id
                         , x_cost_group_id             => v_cost_group_id
                         , x_return_status             => l_return_status
                          );

    IF (l_return_status <> fnd_api.g_ret_sts_success)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('error from inv_cost_group_update.proc_get_costgroup'
                   , 'Validate_cost_group'
                    );
      END IF;

      fnd_message.set_name ('INV', 'INV_ERROR_GET_COST_GROUP');
      fnd_msg_pub.ADD;
      x_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_cost_group_id IS NULL OR l_cost_group_id = -1)
    THEN
      l_cost_group_id := v_cost_group_id;
    ELSIF (l_cost_group_id <> v_cost_group_id)
    THEN
      fnd_message.set_name ('INV', 'INV_INT_CSTGRP');
      fnd_msg_pub.ADD;
      x_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;

    IF (x_rs_cost_group_tbl.COUNT = 0 OR x_rs_cost_group_tbl IS NULL)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('x_rs_cost_group_tbl is null', 'Validate_Cost_Group');
      END IF;

      -- user does not stamp the cost group in the interface table
      -- assign the parent lot cost group
      x_rs_cost_group_tbl := number_table ();
      x_rs_cost_group_tbl.EXTEND (l_result_count);

      FOR i IN 1 .. l_result_count
      LOOP
        x_rs_cost_group_tbl (i) := l_cost_group_id;
      END LOOP;

      l_validation_status := 'Y';
    ELSE
      -- user stamp the cost group. Check if not same as parent lot cost group, throw error.
      FOR i IN 1 .. l_result_count
      LOOP
        IF (x_rs_cost_group_tbl (i) <> l_cost_group_id)
        THEN
          fnd_message.set_name ('INV', 'INV_LOT_DIFF_COSTGROUP');
          fnd_msg_pub.ADD;
          l_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP;

      l_validation_status := 'Y';
    END IF;

    IF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
    THEN
      FOR i IN 2 .. l_start_count
      LOOP
        l_organization_id := p_st_org_id_tbl (i);
        l_inventory_item_id := p_st_item_id_tbl (i);
        l_subinventory_code := p_st_sub_code_tbl (i);
        l_locator_id := p_st_loc_id_tbl (i);
        l_lot_number := p_st_lot_num_tbl (i);
        l_current_cost_group_id := p_st_cost_group_tbl (i);
        l_lpn_id := p_st_lpn_id_tbl (i);
        l_revision := p_st_revision_tbl (i);
        --Bug #5501030
        IF (l_debug = 1) THEN
          print_debug ('l_organization_id is ' || l_organization_id
                     , 'Validate_Cost_Group'
                      );
          print_debug ('l_inventory_item_id is ' || l_inventory_item_id
                     , 'Validate_Cost_Group'
                      );
          print_debug ('l_subinventory_code is ' || l_subinventory_code
                     , 'Validate_Cost_Group'
                      );
          print_debug ('l_locator_id is ' || l_locator_id, 'Validate_Cost_Group');
          print_debug ('l_lot_number is ' || l_lot_number, 'Validate_Cost_Group');
          print_debug ('l_cost_group_id is ' || l_cost_group_id
                     , 'Validate_Cost_Group'
                      );
          print_debug ('l_lpn_id is ' || l_lpn_id, 'Validate_Cost_Group');
          print_debug ('l_revision is ' || l_revision, 'Validate_Cost_Group');
        END IF;

        IF (l_current_cost_group_id IS NULL OR l_current_cost_group_id = -1)
        THEN
          -- get cost group for the parent lot
          IF (l_lpn_id IS NULL)
          THEN
            l_containerized_flag := 2;
          ELSE
            l_containerized_flag := 1;
          END IF;

          inv_cost_group_update.proc_get_costgroup
                          (p_organization_id           => l_organization_id
                         , p_inventory_item_id         => l_inventory_item_id
                         , p_subinventory_code         => l_subinventory_code
                         , p_locator_id                => l_locator_id
                         , p_revision                  => l_revision
                         , p_lot_number                => l_lot_number
                         , p_serial_number             => NULL
                         , p_containerized_flag        => l_containerized_flag
                         , p_lpn_id                    => l_lpn_id
                         , p_transaction_action_id     => p_transaction_action_id
                         , x_cost_group_id             => l_current_cost_group_id
                         , x_return_status             => l_return_status
                          );

          IF (l_return_status <> fnd_api.g_ret_sts_success)
          THEN
            fnd_message.set_name ('INV', 'INV_ERROR_GET_COST_GROUP');
            fnd_msg_pub.ADD;
            x_validation_status := 'N';
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        IF (l_current_cost_group_id <> l_cost_group_id)
        THEN
          fnd_message.set_name ('INV', 'INV_DIFF_MERGE_COST_GROUP');
          fnd_message.set_token ('ENTITY1', l_lot_number);
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        END IF;
      END LOOP;
    ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate)
    THEN
      -- do not assign cost group if the lot changed item.
      IF (l_inventory_item_id <> p_rs_item_id_tbl (1))
      THEN
        -- do nothing. let the trx manager assign the cost group;
        x_validation_status := 'Y';
        x_return_status := fnd_api.g_ret_sts_success;
        fnd_msg_pub.count_and_get (p_count     => x_msg_count
                                 , p_data      => x_msg_data
                                  );
        RETURN;
      END IF;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Material_Status');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_cost_groups;

  /*********************************************************************************************
   * Pseudo-codes:                                                                             *
   *  Call Get_Org_info to get wms_installed, wsm_enabled and wms_enabled flag for             *
   *     The organization                                                                      *
   *                                                                                           *
   *  l_start_count := p_st_lot_num_tbl.COUNT;                                                 *
   *  l_result_count := p_rs_lot_num_tbl.COUNT;                                                *
   *                                                                                           *
   *  Retrieve the primary_uom_code and revision_control for the item and org.                 *
   *                                                                                           *
   *  l_organization_id := p_st_org_id_tbl(1);                                                 *
   *  l_inventory_item_id  := p_st_item_id_tbl(1);                                             *
   *  l_subinventory_code := p_St_sub_code_tbl(1);                                             *
   *  l_locator_id := p_st_loc_id_tbl(1);                                                      *
   *  l_lot_number := p_st_lot_num_tbl(1);                                                     *
   *  l_cost_group_id := p_st_cost_group_tbl(1);                                               *
   *  l_lpn_id := p_st_lpn_id_tbl(1);                                                          *
   *  l_revision := p_st_revision_tbl(1);                                                      *
   *  l_start_uom_code := p_st_uom_tbl(1);                                                     *
   *  l_start_qty := p_st_quantity_tbl(1);                                                     *
   *                                                                                           *
   *  if( this is a lot split or lot translate transaction ) then                              *
   *     -- check if the total result qty do not exceed the parent lot quantity                *
   *                                                                                           *
   *     if( primary uom is different from the uom of the parent lot ) then                    *
   *     -- call inv_um.convert                                                                *
   *   calculate the primary qty of the parent lot by calling                                  *
   *      inv_convert.inv_um_convert                                                           *
   *   end if;                                                                                 *
   *                                                                                           *
   * for i in 1..l_result_count LOOP                                                           *
   *      if( result lot uom <> primary uom of parent lot  ) then                              *
   *             convert to result qty to the primary uom of starting lot.                     *
   *         end if;                                                                           *
   *         l_total_qty := l_total_qty + l_result_qty;                                        *
   *   end loop;                                                                               *
   *  if( l_total_qty = 0 ) then                                                               *
   *   return incorrect transaction qty                                                        *
   *  end if;                                                                                  *
   *                                                                                           *
   *     if( l_total_qty > l_start_primary_qty ) then                                          *
   *      return total quantity exceed quantity to split error                                 *
   *  end if;                                                                                  *
   * else if( transaction is lot merge ) THEN                                                  *
   * for each parent lots record LOOP                                                          *
   *    if( l_start_primary_uom <> p_st_uom_tbl(i) ) then                                      *
   *   convert qty to primary uom                                                              *
   *    end if;                                                                                *
   *    l_total_qty := l_total_qty + l_start_primary_qty;                                      *
   *                                                                                           *
   *     if( l_total_qty = 0 ) then                                                            *
   *   return incorrect transaction qty error                                                  *
   *     end if;                                                                               *
   *     end Loop;                                                                             *
   *                                                                                           *
   *     if( result uom  <> l_start_primary_uom ) then                                         *
   *         -- convert result qty to primary start uom                                        *
   *     end if;                                                                               *
   * if( l_result_qty > l_total_qty ) then                                                     *
   *      return result qty does not match total qty to merge error                            *
   *  end if;                                                                                  *
   * end if;                                                                                   *
   *********************************************************************************************/
  PROCEDURE validate_quantity (
    x_return_status           OUT NOCOPY      VARCHAR2
  , x_msg_count               OUT NOCOPY      NUMBER
  , x_msg_data                OUT NOCOPY      VARCHAR2
  , x_validation_status       OUT NOCOPY      VARCHAR2
  , p_transaction_type_id     IN              NUMBER
  , p_st_org_id_tbl           IN              number_table
  , p_st_item_id_tbl          IN              number_table
  , p_st_sub_code_tbl         IN              sub_code_table
  , p_st_loc_id_tbl           IN              number_table
  , p_st_lot_num_tbl          IN              lot_number_table
  , p_st_cost_group_tbl       IN              number_table
  , p_st_revision_tbl         IN              revision_table
  , p_st_lpn_id_tbl           IN              number_table
  , p_st_quantity_tbl         IN              number_table
  , p_st_uom_tbl              IN              uom_table
  , p_st_ser_number_tbl       IN              serial_number_table
  , p_st_ser_parent_lot_tbl   IN              parent_lot_table
  , p_rs_org_id_tbl           IN              number_table
  , p_rs_item_id_tbl          IN              number_table
  , p_rs_sub_code_tbl         IN              sub_code_table
  , p_rs_loc_id_tbl           IN              number_table
  , p_rs_lot_num_tbl          IN              lot_number_table
  , p_rs_cost_group_tbl       IN              number_table
  , p_rs_revision_tbl         IN              revision_table
  , p_rs_lpn_id_tbl           IN              number_table
  , p_rs_quantity_tbl         IN              number_table
  , p_rs_uom_tbl              IN              uom_table
  , p_rs_ser_number_tbl       IN              serial_number_table
  , p_rs_ser_parent_lot_tbl   IN              parent_lot_table
  )
  IS
    l_wms_installed           VARCHAR2 (1);
    l_wsm_enabled             VARCHAR2 (1);
    l_wms_enabled             VARCHAR2 (1);
    l_start_count             NUMBER;
    l_result_count            NUMBER;
    l_organization_id         NUMBER;
    l_inventory_item_id       NUMBER;
    l_subinventory_code       VARCHAR2 (30);
    l_lot_number              VARCHAR2 (30);
    l_cost_group_id           NUMBER;
    l_current_cost_group_id   NUMBER;
    l_result_cost_group_id    NUMBER;
    l_locator_id              NUMBER;
    l_lpn_id                  NUMBER;
    l_revision                VARCHAR2 (30);
    l_containerized_flag      NUMBER;
    l_start_uom_code          VARCHAR2 (3);
    l_result_uom_code         VARCHAR2 (3);
    l_start_primary_uom       VARCHAR2 (3);
    l_result_primary_uom      VARCHAR2 (3);
    l_start_primary_qty       NUMBER;
    l_start_qty               NUMBER;
    l_result_primary_qty      NUMBER;
    l_result_qty              NUMBER;
    l_total_qty               NUMBER                                  := 0;
    l_temp_qty                NUMBER;
    l_att_qty                 NUMBER;
    l_qoh_qty                 NUMBER;
    l_lpn_qty                 NUMBER;
    l_st_var_index            mtl_serial_numbers.serial_number%TYPE;
    l_rs_var_index            mtl_serial_numbers.serial_number%TYPE;
    l_lot_serial_count        NUMBER;
    l_serial_code             NUMBER;
    l_is_serial_control       VARCHAR2 (10);
    l_return_values           VARCHAR2 (1);
    l_return_msg              VARCHAR2 (200);
    l_revision_control        VARCHAR2 (5);
    l_debug                   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1)
    THEN
      print_debug ('Inside Validate_Quantity', 'Validate_Quantity');
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    x_validation_status := 'Y';

    IF (l_debug = 1)
    THEN
      print_debug ('calling get_org_info', 'Validate_Quantity');
    END IF;

    get_org_info (p_organization_id     => p_st_org_id_tbl (1)
                , x_wms_installed       => l_wms_installed
                , x_wsm_enabled         => l_wsm_enabled
                , x_wms_enabled         => l_wms_enabled
                , x_return_status       => x_return_status
                , x_msg_count           => x_msg_count
                , x_msg_data            => x_msg_data
                 );

    IF (x_return_status = fnd_api.g_ret_sts_error)
    THEN
      RAISE fnd_api.g_exc_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_unexp_error)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF (l_debug = 1)
    THEN
      print_debug ('l_wms_installed is ' || l_wms_installed
                 , 'Validate_Quantity'
                  );
      print_debug ('l_wsm_enabled is ' || l_wsm_enabled, 'Validate_Quantity');
      print_debug ('l_wms_enabled is ' || l_wms_enabled, 'Validate_Quantity');
    END IF;

    l_start_count := p_st_lot_num_tbl.COUNT;
    l_result_count := p_rs_lot_num_tbl.COUNT;
    l_organization_id := p_st_org_id_tbl (1);
    l_inventory_item_id := p_st_item_id_tbl (1);
    l_subinventory_code := p_st_sub_code_tbl (1);
    l_locator_id := p_st_loc_id_tbl (1);
    l_lot_number := p_st_lot_num_tbl (1);
    l_cost_group_id := p_st_cost_group_tbl (1);
    l_lpn_id := p_st_lpn_id_tbl (1);
    l_revision := p_st_revision_tbl (1);
    l_start_uom_code := p_st_uom_tbl (1);
    l_start_qty := p_st_quantity_tbl (1);

    -- get primary uom
    BEGIN
      SELECT primary_uom_code
           , DECODE (revision_qty_control_code, 1, 'FALSE', 'TRUE')
        INTO l_start_primary_uom
           , l_revision_control
        FROM mtl_system_items
       WHERE organization_id = l_organization_id
         AND inventory_item_id = l_inventory_item_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        fnd_message.set_name ('INV', 'INV_INT_ITEM_CODE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
    END;

    IF (l_debug = 1) THEN
      print_debug ('l_start_primary_uom is ' || l_start_primary_uom
                 , 'Validate_Quantity'
                  );
      print_debug ('l_start_count is ' || l_start_count, 'Validate_Quantity');
      print_debug ('l_result_count is ' || l_result_count
                 , 'Validate_Quantity');
    END IF;

    /*Added for OSFM support for Serialized Lot Items.*/
    BEGIN
      SELECT serial_number_control_code
        INTO l_serial_code
        FROM mtl_system_items
       WHERE organization_id = l_organization_id
         AND inventory_item_id = l_inventory_item_id;
    EXCEPTION
      WHEN OTHERS
      THEN
        IF (l_debug = 1) THEN
          print_debug ('Error in getting serial_number control code', 'Validate_Quantity');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
    END;
    IF (l_debug = 1) THEN
      print_debug ('l_serial_code ' || l_serial_code, 'Validate_Quantity');
    END IF;

    IF (l_serial_code IN (2, 5))
    THEN
      l_is_serial_control := 'TRUE';
    ELSE
      l_is_serial_control := 'FALSE';
    END IF;

    IF (   p_transaction_type_id = inv_globals.g_type_inv_lot_split
        OR p_transaction_type_id = inv_globals.g_type_inv_lot_translate
       )
    THEN
      -- check if the total result qty do not exceed the parent lot quantity
      IF (l_start_primary_uom <> p_st_uom_tbl (1))
      THEN
        -- call inv_um.convert
        --bug 8526689  added lot number and org id to make the inv_convert call lot specific
        l_start_primary_qty :=
          inv_convert.inv_um_convert (item_id           => l_inventory_item_id
                                   ,  lot_number    =>  l_lot_number
                                   ,  organization_id   => l_organization_id
                                    , PRECISION         => 5
                                    , from_quantity     => l_start_qty
                                    , from_unit         => l_start_uom_code
                                    , to_unit           => l_start_primary_uom
                                    , from_name         => NULL
                                    , to_name           => NULL
                                     );

        IF (l_start_primary_qty = -99999)
        THEN
          fnd_message.set_name ('INV', 'INV-CANNOT CONVERT');
          fnd_message.set_token ('UOM', l_start_uom_code);
          fnd_message.set_token ('ROUTINE'
                               , g_pkg_name || 'Validate_Quantity');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        l_start_primary_qty := l_start_qty;
      END IF;

      IF (l_debug = 1) THEN
        print_debug ('l_start_primary_qty is ' || l_start_primary_qty, 'Validate_Quantity');
      END IF;

      /*Get the immediate qty of an item in an LPN...
       *this api also validates the loose quantities if lpn_id is NULL
       */
      l_return_values :=
        inv_txn_validations.get_immediate_lpn_item_qty
                                 (p_lpn_id                  => l_lpn_id
                                , p_organization_id         => l_organization_id
                                , p_source_type_id          => -9999
                                , p_inventory_item_id       => l_inventory_item_id
                                , p_revision                => l_revision
                                , p_locator_id              => l_locator_id
                                , p_subinventory_code       => l_subinventory_code
                                , p_lot_number              => l_lot_number
                                , p_is_revision_control     => l_revision_control
                                , p_is_serial_control       => l_is_serial_control
                                , p_is_lot_control          => 'TRUE'
                                , x_transactable_qty        => l_att_qty
                                , x_qoh                     => l_qoh_qty
                                , x_lpn_onhand              => l_lpn_qty
                                , x_return_msg              => l_return_msg
                                 );

      IF (l_return_values <> 'Y') THEN
        IF (l_debug = 1) THEN
          print_debug ('get_immediate_lpn_item_qty has returned error', 'Validate_Quantity');
        END IF;
        fnd_message.set_name ('INV', 'INV_NOT_ENOUGH_ATT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_debug = 1) THEN
        print_debug ('l_att_qty is ' || l_att_qty, 'Validate_Quantity');
        print_debug ('l_qoh_qty is ' || l_qoh_qty, 'Validate_Quantity');
        print_debug ('l_lpn_qty is ' || l_lpn_qty, 'Validate_quantity');
      END IF;

      IF (l_att_qty < l_start_primary_qty) THEN
        fnd_message.set_name ('INV', 'INV_NOT_ENOUGH_ATT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate) THEN
        IF (l_att_qty <> l_start_primary_qty) THEN
          fnd_message.set_name ('INV', 'INV_LOT_TRANSLATE_QTY_ERR');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      FOR i IN 1 .. l_result_count
      LOOP
        IF (l_debug = 1) THEN
          print_debug ('l_rs_uom_tbl is ' || p_rs_uom_tbl (i), 'Validate_Quantity');
        END IF;

        IF (p_rs_uom_tbl (i) <> l_start_primary_uom) THEN
          -- convert to start uom
          --bug 8526689  added lot number and org id to make the inv_convert call lot specific
          l_result_qty :=
            inv_convert.inv_um_convert
                                      (item_id           => l_inventory_item_id
                                     ,  lot_number    =>  p_st_lot_num_tbl(i)
                                     ,  organization_id   => p_st_org_id_tbl(i)
                                     , PRECISION         => 5
                                     , from_quantity     => p_rs_quantity_tbl(i)
                                     , from_unit         => p_rs_uom_tbl (i)
                                     , to_unit           => l_start_primary_uom
                                     , from_name         => NULL
                                     , to_name           => NULL
                                      );

          IF (l_result_qty = -99999) THEN
            fnd_message.set_name ('INV', 'INV-CANNOT CONVERT');
            fnd_message.set_token ('UOM', l_start_uom_code);
            fnd_message.set_token ('ROUTINE', g_pkg_name || 'Validate_Quantity');
            fnd_msg_pub.ADD;
            x_validation_status := 'N';
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          l_result_qty := p_rs_quantity_tbl (i);
        END IF;

        IF (    i = 1
            AND l_result_qty = l_att_qty
            AND p_transaction_type_id = inv_globals.g_type_inv_lot_split
           ) THEN
          fnd_message.set_name ('INV', 'INV_MIN_LOT_SPLIT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        l_total_qty := l_total_qty + l_result_qty;

        IF (l_debug = 1) THEN
          print_debug ('l_total_qty is ' || l_total_qty, 'Validate_Quantity');
        END IF;

        /*Check to see wether individual lot quantities also match*/

        IF(l_is_serial_control = 'TRUE'
           AND p_transaction_type_id = inv_globals.g_type_inv_lot_split) THEN
          l_rs_var_index := p_rs_ser_parent_lot_tbl.FIRST;
          l_lot_serial_count := 0;
          FOR j IN 1 .. p_rs_ser_number_tbl.COUNT
          LOOP
            IF (p_rs_ser_parent_lot_tbl (l_rs_var_index) = p_rs_lot_num_tbl (i)) THEN
              l_lot_serial_count := l_lot_serial_count + 1;
            END IF;
            l_rs_var_index := p_rs_ser_parent_lot_tbl.NEXT (l_rs_var_index);
          END LOOP;

          IF (l_lot_serial_count <> l_result_qty) THEN
            IF (l_debug = 1) THEN
              print_debug ('Lot qty does not match the serial qty for lot split ', 'Validate_Quantity');
              print_debug ('Lot = >  ' || p_rs_lot_num_tbl (i), 'Validate_Quantity');
              print_debug ('l_lot_serial_count = >  ' || l_lot_serial_count, 'Validate_Quantity');
            END IF;
            fnd_message.set_name ('INV', 'INV_INVLTPU_LOTTRX_QTY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END LOOP;

      IF (l_total_qty = 0) THEN
        fnd_message.set_name ('INV', 'INV_INLTPU_QTY');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_total_qty <> l_start_primary_qty) THEN
        IF (    p_transaction_type_id = inv_globals.g_type_inv_lot_split
            AND l_total_qty > l_start_primary_qty) THEN
          x_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_TOTAL_EXCEED_SPLIT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate) THEN
          x_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_TOTAL_EXCEED_TRANSLATE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /*Check for qty matching in case of lot serial items...
       *Serial qty should match the MTLI.primary_quantity
       */
      IF (l_serial_code IN (2, 5)) THEN
        IF (   TRUNC (l_start_primary_qty) <> TRUNC (l_start_primary_qty, 6)
            OR TRUNC (l_total_qty) <> TRUNC (l_total_qty, 6) ) THEN
          IF (l_debug = 1) THEN
            print_debug('Fractional qty is present for a lot serial controlled item'
              , 'Validate_Quantity');
          END IF;
          fnd_message.set_name ('INV', 'INV_LOT_SER_QTY_VIOLATION');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (   p_st_ser_number_tbl.COUNT <> l_start_primary_qty
            OR p_rs_ser_number_tbl.COUNT <> l_total_qty) THEN
          IF (l_debug = 1) THEN
            print_debug('Start/result lot qty does not match the start/result serial records qty'
                          , 'Validate_Quantity');
            print_debug('p_st_ser_number_tbl.COUNT => '|| p_st_ser_number_tbl.COUNT
                          , 'Validate_Quantity');
            print_debug('l_start_primary_qty => ' || l_start_primary_qty
                          , 'Validate_Quantity');
            print_debug(' p_rs_ser_number_tbl.COUNT => ' || p_rs_ser_number_tbl.COUNT
                          , 'Validate_Quantity');
            print_debug('l_total_qty => ' || l_total_qty, 'Validate_Quantity');
          END IF;
          x_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_INVLTPU_LOTTRX_QTY');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    /* for lot merge, the check if the starting lot have enough qty to transact in
     * the transaction manager we don't check it here.
     */
    ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge) THEN
      FOR i IN 1 .. l_start_count
      LOOP
        IF (l_start_primary_uom <> p_st_uom_tbl (i)) THEN
        --bug 8526689  added lot number and org id to make the inv_convert call lot specific
          l_start_primary_qty :=
            inv_convert.inv_um_convert(item_id           => p_st_item_id_tbl(i)
                                     ,  lot_number    =>  p_st_lot_num_tbl(i)
                                     ,  organization_id   => p_st_org_id_tbl(i)
                                     , PRECISION         => 5
                                     , from_quantity     => p_st_quantity_tbl(i)
                                     , from_unit         => p_st_uom_tbl (i)
                                     , to_unit           => l_start_primary_uom
                                     , from_name         => NULL
                                     , to_name           => NULL
                                      );

          IF (l_start_primary_qty = -99999)
          THEN
            fnd_message.set_name ('INV', 'INV-CANNOT CONVERT');
            fnd_message.set_token ('UOM', l_start_uom_code);
            fnd_message.set_token ('ROUTINE'
                                 , g_pkg_name || 'Validate_Quantity'
                                  );
            fnd_msg_pub.ADD;
            x_validation_status := 'N';
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        ELSE
          l_start_primary_qty := p_st_quantity_tbl (i);
        END IF;

        IF (l_debug = 1) THEN
          print_debug('l_start_primary_qty is ' || l_start_primary_qty, 'Validate_Quantity');
          print_debug('p_st_lpn_id_tbl(i) is ' || p_st_lpn_id_tbl(i), 'Validate_Quantity');
          print_debug ('p_st_revision_tbl(i) is ' || p_st_revision_tbl(i), 'Validate_Quantity');
          print_debug ('p_st_sub_code_tbl(i) is ' || p_st_sub_code_tbl(i), 'Validate_Quantity');
          print_debug ('p_st_loc_id_tbl(i) is ' || p_st_loc_id_tbl(i), 'Validate_Quantity');
        END IF;

        --Bug #5501030
        --Pass the revision to quantity tree by reading from table
        l_return_values :=
          inv_txn_validations.get_immediate_lpn_item_qty
                                 (p_lpn_id                  => p_st_lpn_id_tbl(i)
                                , p_organization_id         => l_organization_id
                                , p_source_type_id          => -9999
                                , p_inventory_item_id       => l_inventory_item_id
                                , p_revision                => p_st_revision_tbl(i)
                                , p_locator_id              => p_st_loc_id_tbl(i)
                                , p_subinventory_code       => p_st_sub_code_tbl(i)
                                , p_lot_number              => p_st_lot_num_tbl(i)
                                , p_is_revision_control     => l_revision_control
                                , p_is_serial_control       => l_is_serial_control
                                , p_is_lot_control          => 'TRUE'
                                , x_transactable_qty        => l_att_qty
                                , x_qoh                     => l_qoh_qty
                                , x_lpn_onhand              => l_lpn_qty
                                , x_return_msg              => l_return_msg
                                 );

        IF (l_return_values <> 'Y') THEN
          IF (l_debug = 1) THEN
            print_debug ('get_immediates_lpn_qty returned error', 'Validate_Quantity');
          END IF;
          fnd_message.set_name ('INV', 'INV_NOT_ENOUGH_ATT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_debug = 1) THEN
          print_debug ('l_att_qty is ' || l_att_qty, 'Validate_Quantity');
          print_debug ('l_qoh_qty is ' || l_qoh_qty, 'Validate_Quantity');
          print_debug ('l_lpn_qty is ' || l_lpn_qty, 'Validate_quantity');
        END IF;

        IF (l_att_qty < l_start_primary_qty) THEN
          fnd_message.set_name ('INV', 'INV_NOT_ENOUGH_ATT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        /*OSFM support for Serialized Lot Items
         *Need to calculate the serial numbers for each lot ..it should match with the
         *lot quantity..
         */
        IF (l_serial_code IN (2, 5)) THEN
          l_st_var_index := p_st_ser_parent_lot_tbl.FIRST;
          l_lot_serial_count := 0;

          FOR j IN 1 .. p_st_ser_number_tbl.COUNT LOOP
            IF (p_st_ser_parent_lot_tbl (l_st_var_index) = p_st_lot_num_tbl (i))
            THEN
              l_lot_serial_count := l_lot_serial_count + 1;
            END IF;
            l_st_var_index := p_st_ser_parent_lot_tbl.NEXT (l_st_var_index);
          END LOOP;

          IF (l_lot_serial_count <> l_start_primary_qty) THEN
            IF (l_debug = 1) THEN
              print_debug ('Lot qty does not match the serial qty ', 'Validate_Quantity');
              print_debug ('Lot = >  ' || p_st_lot_num_tbl (i), 'Validate_Quantity');
              print_debug ('l_lot_serial_count = >  ' || l_lot_serial_count, 'Validate_Quantity');
            END IF;
            fnd_message.set_name ('INV', 'INV_INVLTPU_LOTTRX_QTY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;

        l_total_qty := l_total_qty + l_start_primary_qty;
        IF (l_debug = 1) THEN
          print_debug ('l_total_qty is ' || l_total_qty, 'Validate_Quantity');
        END IF;
      END LOOP;

      IF (p_rs_uom_tbl (1) <> l_start_primary_uom) THEN
        -- convert to start uom
        --bug 8526689  added lot number and org id to make the inv_convert call lot specific
        l_result_qty :=
          inv_convert.inv_um_convert (item_id           => l_inventory_item_id
                                    ,  lot_number    =>  l_lot_number
                                    ,  organization_id   => l_organization_id
                                    , PRECISION         => 5
                                    , from_quantity     => p_rs_quantity_tbl(1)
                                    , from_unit         => p_rs_uom_tbl (1)
                                    , to_unit           => l_start_primary_uom
                                    , from_name         => NULL
                                    , to_name           => NULL
                                     );

        IF (l_result_qty = -99999)
        THEN
          fnd_message.set_name ('INV', 'INV-CANNOT CONVERT');
          fnd_message.set_token ('UOM', l_start_uom_code);
          fnd_message.set_token ('ROUTINE', g_pkg_name || 'Validate_Quantity');
          fnd_msg_pub.ADD;
          x_validation_status := 'N';
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      ELSE
        l_result_qty := p_rs_quantity_tbl (1);
      END IF;

      IF (l_debug = 1) THEN
        print_debug ('l_result_qty is ' || l_result_qty, 'Validate_Quantity');
      END IF;


      IF (l_result_qty <> l_total_qty) THEN
        x_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_QTY_NOT_MATCHED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /*For lot - serial items*/
      IF (l_serial_code IN (2, 5)) THEN
        IF (   TRUNC (l_start_primary_qty) <> TRUNC (l_start_primary_qty, 6)
            OR TRUNC (l_total_qty) <> TRUNC (l_total_qty, 6) ) THEN
          fnd_message.set_name ('INV', 'INV_LOT_SER_QTY_VIOLATION');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (   p_st_ser_number_tbl.COUNT <> l_total_qty
            OR p_rs_ser_number_tbl.COUNT <> l_result_qty ) THEN
          x_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_INVLTPU_LOTTRX_QTY');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Quantity');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_quantity;

  /*********************************************************************************************
   * This procedure will validate the organization, checks if the Organization chosen
   * has a open period and also check if the acct_period_id pass is valid.
   *********************************************************************************************/
  PROCEDURE validate_organization (
    x_return_status       OUT NOCOPY      VARCHAR2
  , x_msg_count           OUT NOCOPY      NUMBER
  , x_msg_data            OUT NOCOPY      VARCHAR2
  , x_validation_status   OUT NOCOPY      VARCHAR2
  , p_organization_id     IN              NUMBER
  , p_period_tbl          IN              number_table
  )
  IS
    l_period_tbl_id   NUMBER;
    l_period_id       NUMBER;
  BEGIN
    IF (p_organization_id IS NULL)
    THEN
      fnd_message.set_name ('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      x_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    END IF;

    print_debug ('Inside Validate_Organization', 'Validate_Organization');
    print_debug ('p_organization_id is ' || p_organization_id
               , 'Validate_Organization'
                );
    inv_inv_lovs.tdatechk (p_organization_id, SYSDATE, l_period_id);
    print_debug ('l_period_id is ' || l_period_id, 'Validate_Organization');

    FOR i IN 1 .. p_period_tbl.COUNT
    LOOP
      l_period_tbl_id := p_period_tbl (i);
      print_debug ('p_period_tbl_id is ' || l_period_tbl_id
                 , 'Validate_Organization'
                  );

      IF (   l_period_tbl_id <> l_period_id
          OR l_period_tbl_id = 0
          OR l_period_tbl_id = -1
         )
      THEN
        fnd_message.set_name ('INV', 'INV_NO_OPEN_PERIOD');
        fnd_msg_pub.ADD;
        x_validation_status := 'N';
        RAISE fnd_api.g_exc_error;
      END IF;
    END LOOP;

    IF (l_period_id = 0 OR l_period_id = -1)
    THEN
      fnd_message.set_name ('INV', 'INV_NO_OPEN_PERIOD');
      fnd_msg_pub.ADD;
      x_validation_status := 'N';
      RAISE fnd_api.g_exc_error;
    ELSE
      x_validation_status := 'Y';
      x_return_status := fnd_api.g_ret_sts_success;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_Organization');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_organization;

  /***********************************Validate_Serials*************************
    Perform basic validations for the serials present in the Lot transactions.
    -> Source Serials should match Resulting Serials in Count and Serial Number
    -> Source Serials should be available for transactions. (GM ID validation)
    -> Serial Material status validation for the source Serials.
    -> If Lot Translate and Item Id changed Then
        Call INV_SERIAL_NUMBER_PUB.validate_serials.
        This will perform uniqueness
        check and if possible create the new serial for the Resulting Item.
       End IF
  ****************************************************************************/
  PROCEDURE validate_serials (
    x_return_status            OUT NOCOPY      VARCHAR2
  , x_msg_count                OUT NOCOPY      NUMBER
  , x_msg_data                 OUT NOCOPY      VARCHAR2
  , x_validation_status        OUT NOCOPY      VARCHAR2
  , p_transaction_type_id      IN              NUMBER
  , p_st_org_id_tbl            IN              number_table
  , p_rs_org_id_tbl            IN              number_table
  , p_st_item_id_tbl           IN              number_table
  , p_rs_item_id_tbl           IN              number_table
  , p_rs_lot_num_tbl           IN              lot_number_table
  , p_st_quantity_tbl          IN              number_table
  , p_st_sub_code_tbl          IN              sub_code_table
  , p_st_locator_id_tbl        IN              number_table
  , p_st_ser_number_tbl        IN              serial_number_table
  , p_st_ser_parent_lot_tbl    IN              parent_lot_table
  , p_rs_ser_number_tbl        IN              serial_number_table
  , p_st_ser_status_tbl        IN              number_table
  , p_st_ser_grp_mark_id_tbl   IN              number_table
  , p_st_ser_parent_sub_tbl    IN              parent_sub_table
  , p_st_ser_parent_loc_tbl    IN              parent_loc_table
  )
  IS
    l_proc_msg            VARCHAR2 (255);
    l_end_ser             mtl_serial_numbers.serial_number%TYPE;
    l_qty                 NUMBER;
    l_st_var_index        mtl_serial_numbers.serial_number%TYPE;
    l_rs_var_index        mtl_serial_numbers.serial_number%TYPE;
    l_debug               NUMBER;
    l_validation_status   VARCHAR2 (1);
    l_primary_uom         VARCHAR2(10);

  BEGIN
    l_debug := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
    l_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;

    IF (p_transaction_type_id IS NULL)
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 10', 'Validate_serials');
        print_debug ('p_transaction_type_id is NULL', 'Validate_serials');
      END IF;

      l_validation_status := 'N';
      fnd_message.set_name ('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_st_var_index := p_st_ser_number_tbl.FIRST;
    l_rs_var_index := p_rs_ser_number_tbl.FIRST;

    FOR i IN 1 .. p_st_ser_number_tbl.COUNT
    LOOP
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 20', 'Validate_serials');
      END IF;

      IF ((p_transaction_type_id <> inv_globals.g_type_inv_lot_split
          OR (p_transaction_type_id = inv_globals.g_type_inv_lot_split
               AND i <= p_rs_ser_number_tbl.COUNT))
          AND
          p_st_ser_number_tbl (l_st_var_index) <>
                                          p_rs_ser_number_tbl (l_rs_var_index)
          )
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 30', 'Validate_serials');
          print_debug ('Mismtach between start and result serials'
                     , 'Validate_serials'
                      );
        END IF;

        l_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_SERIAL_MATCH_ERROR');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      /*Bug:5147899. Modified the following condition to throw error
        only when the group_mark_id holds a not null value other than -1 */
      ELSIF (     p_st_ser_grp_mark_id_tbl (i) IS NOT NULL
              AND p_st_ser_grp_mark_id_tbl (i) <> -1
            )
      THEN
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 40', 'Validate_serials');
          print_debug (   'Group mark Id validation failed for serial => '
                       || p_st_ser_grp_mark_id_tbl (i)
                     , 'Validate_serials'
                      );
        END IF;

        l_validation_status := 'N';
        fnd_message.set_name ('INV', 'INV_SERIAL_IN_USE');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        /*Lot status validations are done in lot_trx_split_validations seperately.
         *Here we are only concerned with serial status validations.
         *For Lot Split/Translation/Merge transactions we will only validate the status control for the
         *source serials
         */
        BEGIN
          IF (p_transaction_type_id IN
                (inv_globals.g_type_inv_lot_translate
               , inv_globals.g_type_inv_lot_split
                )
             )
          THEN
            IF (l_debug = 1)
            THEN
              print_debug ('breadcrumb 50', 'Validate_serials');
              print_debug
                    ('Calling validate_serial_status for translate OR split'
                   , 'Validate_serials'
                    );
            END IF;

            validate_serial_status
                      (x_return_status           => x_return_status
                     , x_msg_count               => x_msg_count
                     , x_msg_data                => x_msg_data
                     , x_validation_status       => l_validation_status
                     , p_transaction_type_id     => p_transaction_type_id
                     , p_organization_id         => p_st_org_id_tbl (1)
                     , p_inventory_item_id       => p_st_item_id_tbl (1)
                     , p_serial_number           => p_st_ser_number_tbl
                                                               (l_st_var_index)
                     , p_subinventory_code       => p_st_sub_code_tbl (1)
                     , p_locator_id              => p_st_locator_id_tbl (1)
                     , p_status_id               => p_st_ser_status_tbl (i)
                      );

            IF (l_debug = 1)
            THEN
              print_debug ('breadcrumb 60', 'Validate_serials');
            END IF;
          ELSIF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
          THEN
            IF (l_debug = 1)
            THEN
              print_debug ('breadcrumb 70', 'Validate_serials');
              print_debug ('Calling validate_serial_status for lot merge'
                         , 'Validate_serials'
                          );
              print_debug ('p_transaction_type_id ' || p_transaction_type_id
                         , 'Validate_serials'
                          );
              print_debug ('p_st_org_id_tbl (1) ' || p_st_org_id_tbl (1)
                         , 'Validate_serials'
                          );
              print_debug ('p_st_item_id_tbl (1) ' || p_st_item_id_tbl (1)
                         , 'Validate_serials'
                          );
              print_debug ('p_st_ser_number_tbl(l_st_var_index) ' || p_st_ser_number_tbl(l_st_var_index)
                         , 'Validate_serials'
                          );
              print_debug ('p_st_ser_parent_sub_tbl (l_st_var_index) ' || p_st_ser_parent_sub_tbl (l_st_var_index)
                         , 'Validate_serials'
                          );
              print_debug ('p_st_ser_parent_loc_tbl (l_st_var_index)' ||p_st_ser_parent_loc_tbl (l_st_var_index)
                         , 'Validate_serials'
                          );
              print_debug ('p_st_ser_status_tbl (i) ' || p_st_ser_status_tbl (i)
                         , 'Validate_serials'
                          );

            END IF;

            inv_lot_trx_validation_pub.validate_serial_status
                      (x_return_status           => x_return_status
                     , x_msg_count               => x_msg_count
                     , x_msg_data                => x_msg_data
                     , x_validation_status       => l_validation_status
                     , p_transaction_type_id     => p_transaction_type_id
                     , p_organization_id         => p_st_org_id_tbl (1)
                     , p_inventory_item_id       => p_st_item_id_tbl (1)
                     , p_serial_number           => p_st_ser_number_tbl(l_st_var_index)
                     , p_subinventory_code       => p_st_ser_parent_sub_tbl(l_st_var_index)
                     , p_locator_id              => p_st_ser_parent_loc_tbl(l_st_var_index)
                     , p_status_id               => p_st_ser_status_tbl (i)
                      );
            IF (l_debug = 1)
            THEN
              print_debug ('breadcrumb 80', 'Validate_serials');
            END IF;
          END IF;
        EXCEPTION
          WHEN OTHERS
          THEN
            IF (l_debug = 1)
            THEN
              print_debug ('breadcrumb 90', 'Validate_serials');
              print_debug ('validate_serial_status rasied exception'
                         , 'Validate_serials'
                          );
            END IF;

            fnd_message.set_name ('WMS', 'WMS_VALIDATE_STATUS_ERROR');
            fnd_msg_pub.ADD;
            fnd_msg_pub.count_and_get (p_count     => x_msg_count
                                     , p_data      => x_msg_data
                                      );
            l_validation_status := 'N';
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        IF (x_return_status = fnd_api.g_ret_sts_error)
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('breadcrumb 100', 'Validate_serials');
            print_debug ('validate_serial_status returned with error'
                       , 'Validate_serials'
                        );
          END IF;

          l_validation_status := 'N';
          RAISE fnd_api.g_exc_error;
        ELSIF (   x_return_status = fnd_api.g_ret_sts_unexp_error
               OR l_validation_status <> 'Y'
              )
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('breadcrumb 110', 'Validate_serials');
            print_debug ('validate_serial_status returned with error (2)'
                       , 'Validate_serials'
                        );
          END IF;

          RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      l_st_var_index := p_st_ser_number_tbl.NEXT (l_st_var_index);
      l_rs_var_index := p_rs_ser_number_tbl.NEXT (l_rs_var_index);
    END LOOP;

    /*Not calling validate_serials for lot split and merge transactions as most
     *of the validations have already been done.
     */
    IF (    p_transaction_type_id = inv_globals.g_type_inv_lot_translate
        AND p_st_item_id_tbl (1) <> p_rs_item_id_tbl (1)
       )
    THEN
      IF (l_debug = 1)
      THEN
        print_debug ('breadcrumb 120', 'Validate_serials');
      END IF;

      l_rs_var_index := p_rs_ser_number_tbl.FIRST;

      FOR i IN 1 .. p_rs_ser_number_tbl.COUNT
      LOOP
        /*We are calling validate_serials so that if the item does not have this serial
         *then validate_serials will create a new serial. If the item has the serial in status
         *IN_STORES this validation should fail but not if it is in status UNDEFINED
         */
        IF (l_debug = 1)
        THEN
          print_debug ('breadcrumb 130', 'Validate_serials');
          print_debug ('Calling INV_SERIAL_NUMBER_PUB.VALIDATE_SERIALS', 'Validate_serials');
        END IF;
        l_qty := 0;
        l_end_ser := p_rs_ser_number_tbl(l_rs_var_index);
        IF (inv_serial_number_pub.validate_serials
                          (p_org_id                    => p_rs_org_id_tbl (1)
                         , p_item_id                   => p_rs_item_id_tbl (1)
                         , p_qty                       => l_qty
                         , p_lot                       => p_rs_lot_num_tbl (1)
                         , p_start_ser                 => p_rs_ser_number_tbl(l_rs_var_index)
                         , p_trx_src_id                => inv_globals.g_sourcetype_inventory
                         , p_trx_action_id             => inv_globals.g_action_inv_lot_translate
                         , p_issue_receipt             => 'R'
                         , p_check_for_grp_mark_id     => 'Y'
                         , x_end_ser                   => l_end_ser
                         , x_proc_msg                  => l_proc_msg
                          ) = 1
           )
        THEN
          IF (l_debug = 1)
          THEN
            print_debug ('breadcrumb 140', 'Validate_serials');
          END IF;

          l_validation_status := 'N';
          fnd_message.set_name ('INV', 'INV_FAIL_VALIDATE_SERIAL');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        l_rs_var_index := p_rs_ser_number_tbl.NEXT (l_rs_var_index);
      END LOOP;
    END IF;

    x_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    IF (l_debug = 1)
    THEN
      print_debug ('breadcrumb 150', 'Validate_serials');
      print_debug ('Serial Validations passed', 'Validate_serials');
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_validation_status := l_validation_status;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_validation_status := 'E';
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'Validate_serials');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END validate_serials;

  /*********************************************************************************************
     * This procedure will validate the lot expiration dates based on the
       shelf life code and depending on the type of lot transaction update
       the interface table with the correct shelf life code and shelf life dates
     *********************************************************************************************/
  PROCEDURE compute_lot_expiration (
    x_return_status         OUT NOCOPY      VARCHAR2
  , x_msg_count             OUT NOCOPY     NUMBER
  , x_msg_data              OUT NOCOPY     VARCHAR2
  , p_parent_id             IN       NUMBER
  , p_transaction_type_id   IN       NUMBER
  , p_item_id               IN       NUMBER
  , p_organization_id       IN       NUMBER
  , p_st_lot_num            IN       VARCHAR2
  , p_rs_lot_num_tbl        IN       lot_number_table
  , p_rs_lot_exp_tbl        IN OUT NOCOPY  date_table
  )
  IS
    l_shelf_life_code   NUMBER;
    l_shelf_life_days   NUMBER;
    l_lotexpdate        VARCHAR2 (22);
    l_update            BOOLEAN;
  BEGIN
    BEGIN
      SELECT shelf_life_code
           , shelf_life_days
        INTO l_shelf_life_code
           , l_shelf_life_days
        FROM mtl_system_items
       WHERE inventory_item_id = p_item_id
         AND organization_id = p_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        fnd_message.set_name ('INV', 'INV_INVALID_ITEM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
    END;

    print_debug ('Shelf Life Period ' || l_shelf_life_code, 'Compute Lot Exp');
    print_debug ('Item ' || p_item_id, 'Compute Lot Exp');
    print_debug ('Org ' || p_organization_id, 'Compute Lot Exp');
    print_debug ('Parent _id ' || p_parent_id, 'Compute Lot Exp');
    print_debug ('Transaction Type id ' || p_transaction_type_id
               , 'Compute lot Exp'
                );
    print_debug ('Start Lot ' || p_st_lot_num, 'Compute Lot Exp');

    IF (l_shelf_life_code = 2)
    THEN                               -- It is shelf life controlled. Get the
      --lot exp. date from the parent lot MTLN - pass the starting lot number.
      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_split)
      THEN
        BEGIN
          SELECT fnd_date.date_to_canonical (expiration_date)
            INTO l_lotexpdate
            FROM mtl_lot_numbers
           WHERE inventory_item_id = p_item_id
             AND organization_id = p_organization_id
             AND lot_number = p_st_lot_num;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            fnd_message.set_name ('INV', 'INV_INVALID_LOT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        print_debug ('Lot exp date after split1 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );

        IF (l_lotexpdate IS NULL)
        THEN
          fnd_message.set_name ('INV', 'INV_INVALID_LOT_EXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Update all the resulting lots with this exp date
        FOR i IN 1 .. p_rs_lot_exp_tbl.COUNT
        LOOP
          p_rs_lot_exp_tbl (i) := fnd_date.canonical_to_date (l_lotexpdate);
        END LOOP;

        print_debug ('Lot exp date after split2 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );

        BEGIN
          UPDATE mtl_transaction_lots_interface mtli
             SET lot_expiration_date =
                                     fnd_date.canonical_to_date (l_lotexpdate)
           WHERE transaction_interface_id IN (
                   SELECT transaction_interface_id
                     FROM mtl_transactions_interface mti
                    WHERE mti.parent_id = p_parent_id
                      AND mti.transaction_interface_id =
                                                 mtli.transaction_interface_id);
        EXCEPTION
          WHEN OTHERS
          THEN
            fnd_message.set_name ('INV', 'INV_UPDATE_ERROR');
            fnd_message.set_token ('ENTITY1'
                                 , 'MTL_TRANSACTION_LOTS_INTERFACE'
                                  );
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        print_debug ('Lot exp date after split3 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );
      END IF;

      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
      THEN
        -- pass the resulting lot. if the resulting lot doesnt exist, then
        -- get the starting lot with the highest/rep lot and get the
        -- expiration DATE of that lot from the table. pass both in this case.
        BEGIN
          SELECT fnd_date.date_to_canonical (expiration_date)
            INTO l_lotexpdate
            FROM mtl_lot_numbers
           WHERE inventory_item_id = p_item_id
             AND organization_id = p_organization_id
             AND lot_number = p_rs_lot_num_tbl (1);
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN                             -- then get the exp date of the lot
            --either WITH the highet qty OR the rep. lot
            SELECT fnd_date.date_to_canonical (expiration_date)
              INTO l_lotexpdate
              FROM mtl_lot_numbers
             WHERE inventory_item_id = p_item_id
               AND organization_id = p_organization_id
               AND lot_number = p_st_lot_num;              -- We only pass one
        -- lot here based on the highest qty or the rep. lot.
        END;

        print_debug ('Lot exp date after merge1 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );

        IF (l_lotexpdate IS NULL)
        THEN
          fnd_message.set_name ('INV', 'INV_INVALID_LOT_EXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        p_rs_lot_exp_tbl (1) := fnd_date.canonical_to_date (l_lotexpdate);

        -- update the resulting lot with the exp. date.
        BEGIN
          UPDATE mtl_transaction_lots_interface mtli
             SET lot_expiration_date =
                                     fnd_date.canonical_to_date (l_lotexpdate)
           WHERE transaction_interface_id IN (
                   SELECT transaction_interface_id
                     FROM mtl_transactions_interface mti
                    WHERE mti.parent_id = p_parent_id
                      AND mti.parent_id = mti.transaction_interface_id
                      AND mti.transaction_interface_id =
                                                 mtli.transaction_interface_id);
        EXCEPTION
          WHEN OTHERS
          THEN
            fnd_message.set_name ('INV', 'INV_UPDATE_ERROR');
            fnd_message.set_token ('ENTITY1'
                                 , 'MTL_TRANSACTION_LOTS_INTERFACE'
                                  );
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        print_debug ('Lot exp date update merge2 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );
      END IF;

      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate)
      THEN
        BEGIN
          SELECT fnd_date.date_to_canonical (expiration_date)
            INTO l_lotexpdate
            FROM mtl_lot_numbers
           WHERE inventory_item_id = p_item_id
             AND organization_id = p_organization_id
             AND lot_number = p_st_lot_num;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            fnd_message.set_name ('INV', 'INV_INVALID_LOT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        print_debug ('Lot exp date after translate1 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );

        IF (l_lotexpdate IS NULL)
        THEN
          fnd_message.set_name ('INV', 'INV_INVALID_LOT_EXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        BEGIN
          UPDATE mtl_transaction_lots_interface mtli
             SET lot_expiration_date =
                                     fnd_date.canonical_to_date (l_lotexpdate)
           WHERE transaction_interface_id IN (
                   SELECT transaction_interface_id
                     FROM mtl_transactions_interface mti
                    WHERE mti.parent_id = p_parent_id
                      AND mti.transaction_interface_id =
                                                 mtli.transaction_interface_id);
        EXCEPTION
          WHEN OTHERS
          THEN
            fnd_message.set_name ('INV', 'INV_UPDATE_ERROR');
            fnd_message.set_token ('ENTITY1'
                                 , 'MTL_TRANSACTION_LOTS_INTERFACE'
                                  );
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        print_debug ('Lot exp date update translate2 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );
      END IF;
    ELSIF (l_shelf_life_code = 4)
    THEN
      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_split)
      THEN
        -- get all the child records and check to see if the lot is
        -- specified. If it is, then use it. - else get the exp. date
        -- from the starting lot.
        BEGIN
          SELECT fnd_date.date_to_canonical (expiration_date)
            INTO l_lotexpdate
            FROM mtl_lot_numbers
           WHERE inventory_item_id = p_item_id
             AND organization_id = p_organization_id
             AND lot_number = p_st_lot_num;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            fnd_message.set_name ('INV', 'INV_INVALID_LOT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        print_debug ('Lot exp date user defined :split1 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );

        -- Update all the resulting lots with this exp date
        FOR i IN 1 .. p_rs_lot_exp_tbl.COUNT
        LOOP
          IF (p_rs_lot_exp_tbl (i) IS NULL)
          THEN
            p_rs_lot_exp_tbl (i) := fnd_date.canonical_to_date (l_lotexpdate);
          END IF;
        END LOOP;

        print_debug ('Lot exp date user defined :split2 ' || l_lotexpdate
                   , 'Compute Lot Exp'
                    );

        IF (l_lotexpdate IS NULL)
        THEN
          fnd_message.set_name ('INV', 'INV_INVALID_LOT_EXP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        BEGIN
          UPDATE mtl_transaction_lots_interface mtli
             SET lot_expiration_date =
                                     fnd_date.canonical_to_date (l_lotexpdate)
           WHERE transaction_interface_id IN (
                   SELECT transaction_interface_id
                     FROM mtl_transactions_interface mti
                    WHERE mti.parent_id = p_parent_id
                      AND mti.transaction_interface_id =
                                                 mtli.transaction_interface_id
                      AND mtli.lot_expiration_date IS NULL);
        EXCEPTION
          WHEN OTHERS
          THEN
            fnd_message.set_name ('INV', 'INV_UPDATE_ERROR');
            fnd_message.set_token ('ENTITY1'
                                 , 'MTL_TRANSACTION_LOTS_INTERFACE'
                                  );
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
        END;

        print_debug (   'Lot exp date user defined : after update split3 '
                     || l_lotexpdate
                   , 'Compute Lot Exp'
                    );
      END IF;

      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_merge)
      THEN
        l_update := TRUE;

        BEGIN
          SELECT fnd_date.date_to_canonical (expiration_date)
            INTO l_lotexpdate
            FROM mtl_lot_numbers
           WHERE inventory_item_id = p_item_id
             AND organization_id = p_organization_id
             AND lot_number = p_rs_lot_num_tbl (1);
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            print_debug ('Lot exp date user defined : Merge1' || l_lotexpdate
                       , 'Compute Lot Exp'
                        );

            IF (p_rs_lot_exp_tbl (1) IS NULL)
            THEN
              BEGIN
                SELECT fnd_date.date_to_canonical (expiration_date)
                  INTO l_lotexpdate
                  FROM mtl_lot_numbers
                 WHERE inventory_item_id = p_item_id
                   AND organization_id = p_organization_id
                   AND lot_number = p_st_lot_num;
              EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                  print_debug (   'Lot exp date user defined : Merge2 '
                               || l_lotexpdate
                             , 'Compute Lot Exp'
                              );
                  fnd_message.set_name ('INV', 'INV_INVALID_LOT');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_unexpected_error;
              END;

              print_debug (   'Lot exp date user defined : Merge3 '
                           || l_lotexpdate
                         , 'Compute Lot Exp'
                          );
            ELSE
              l_update := FALSE;
              print_debug ('Lot exp date user defined : Merge5'
                           || l_lotexpdate
                         , 'Compute Lot Exp'
                          );
            END IF;
        END;

        IF l_update
        THEN
          IF (l_lotexpdate IS NULL)
          THEN
            fnd_message.set_name ('INV', 'INV_INVALID_LOT_EXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          BEGIN
            UPDATE mtl_transaction_lots_interface mtli
               SET lot_expiration_date =
                                     fnd_date.canonical_to_date (l_lotexpdate)
             WHERE transaction_interface_id IN (
                     SELECT transaction_interface_id
                       FROM mtl_transactions_interface mti
                      WHERE mti.parent_id = p_parent_id
                        AND mti.parent_id = mti.transaction_interface_id
                        AND mti.transaction_interface_id =
                                                 mtli.transaction_interface_id);
          EXCEPTION
            WHEN OTHERS
            THEN
              fnd_message.set_name ('INV', 'INV_UPDATE_ERROR');
              fnd_message.set_token ('ENTITY1'
                                   , 'MTL_TRANSACTION_LOTS_INTERFACE'
                                    );
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
          END;

          print_debug (   'Lot exp date user defined : after update Merge6 '
                       || l_lotexpdate
                     , 'Compute Lot Exp'
                      );
        END IF;
      END IF;

      IF (p_transaction_type_id = inv_globals.g_type_inv_lot_translate)
      THEN
        IF (p_rs_lot_exp_tbl (1) IS NULL)
        THEN
          BEGIN
            SELECT fnd_date.date_to_canonical (expiration_date)
              INTO l_lotexpdate
              FROM mtl_lot_numbers
             WHERE inventory_item_id = p_item_id
               AND organization_id = p_organization_id
               AND lot_number = p_st_lot_num;
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              fnd_message.set_name ('INV', 'INV_INVALID_LOT');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
          END;

          print_debug (   'Lot exp date user defined : Translate1 '
                       || l_lotexpdate
                     , 'Compute Lot Exp'
                      );

          IF (l_lotexpdate IS NULL)
          THEN
            fnd_message.set_name ('INV', 'INV_INVALID_LOT_EXP');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          BEGIN
            UPDATE mtl_transaction_lots_interface mtli
               SET lot_expiration_date =
                                     fnd_date.canonical_to_date (l_lotexpdate)
             WHERE transaction_interface_id IN (
                     SELECT transaction_interface_id
                       FROM mtl_transactions_interface mti
                      WHERE mti.parent_id = p_parent_id
                        AND mti.transaction_interface_id =
                                                 mtli.transaction_interface_id
                        AND mtli.lot_expiration_date IS NULL);
          EXCEPTION
            WHEN OTHERS
            THEN
              fnd_message.set_name ('INV', 'INV_UPDATE_ERROR');
              fnd_message.set_token ('ENTITY1'
                                   , 'MTL_TRANSACTION_LOTS_INTERFACE'
                                    );
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_unexpected_error;
          END;

          print_debug
                     (   'Lot exp date user defined : after update Translate'
                      || l_lotexpdate
                    , 'Compute Lot Exp'
                     );
        END IF;
      END IF;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;
    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'compute_lot_expiration');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
  END compute_lot_expiration;

  PROCEDURE update_item_serial (
    x_msg_count                  OUT NOCOPY      VARCHAR2
  , x_return_status              OUT NOCOPY      VARCHAR2
  , x_msg_data                   OUT NOCOPY      VARCHAR2
  , x_validation_status          OUT NOCOPY      VARCHAR2
  , p_org_id                     IN              NUMBER
  , p_item_id                    IN              NUMBER
  , p_to_item_id                 IN              NUMBER DEFAULT NULL
  , p_wip_entity_id              IN              NUMBER
  , p_to_wip_entity_id           IN              NUMBER DEFAULT NULL
  , p_to_operation_sequence      IN              NUMBER DEFAULT NULL
  , p_intraoperation_step_type   IN              NUMBER DEFAULT NULL
  )
  IS
    l_restrict_serial_rcpt       NUMBER;
    rollback_serial_update     EXCEPTION;

    TYPE osfm_ser_tbl IS TABLE OF mtl_serial_numbers.serial_number%TYPE;

    l_ser_number_tbl             osfm_ser_tbl;
    l_attributes_default_count   NUMBER;
    l_ret                        NUMBER;
    l_context_value_item         VARCHAR2 (30) := NULL;
    l_context_value_to_item      VARCHAR2 (30) := NULL;
    l_update_attr                BOOLEAN       := FALSE;
    l_debug                      BOOLEAN       := TRUE;
  BEGIN
    x_validation_status := 'Y';
    x_return_status := fnd_api.g_ret_sts_success;

    IF (NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0) = 0)
    THEN
      l_debug := FALSE;
    END IF;

    IF (l_debug)
    THEN
      print_debug ('p_inventory_item_id is ' || p_item_id
                 , 'update_item_serial'
                  );
      print_debug ('p_wip_entity_id is ' || p_wip_entity_id
                 , 'update_item_serial'
                  );
      print_debug ('p_to_inventory_item_id is ' || p_to_item_id
                 , 'update_item_serial'
                  );
      print_debug ('p_to_wip_entity_id is ' || p_to_wip_entity_id
                 , 'update_item_serial'
                  );
      print_debug ('p_to_operation_sequence is ' || p_to_operation_sequence
                 , 'update_item_serial'
                  );
      print_debug (   'p_intra_operation_step_type is '
                   || p_intraoperation_step_type
                 , 'update_item_serial'
                  );
    END IF;

    IF (p_item_id IS NULL OR p_wip_entity_id IS NULL OR p_org_id IS NULL)
    THEN
      IF (l_debug)
      THEN
        print_debug ('Either item id or wip entity id or org id is NULL'
                   , 'update_item_serial'
                    );
      END IF;

      x_validation_status := 'N';
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    SAVEPOINT initial_state_svpt;
    l_restrict_serial_rcpt :=
                          NVL (fnd_profile.VALUE ('INV_RESTRICT_RCPT_SER'), 2);

    IF (l_debug)
    THEN
      print_debug ('l_restrict_serial_rcpt ' || l_restrict_serial_rcpt
                 , 'update_item_serial'
                  );
    END IF;

    SELECT serial_number
    BULK COLLECT INTO l_ser_number_tbl
      FROM mtl_serial_numbers msn
     WHERE msn.inventory_item_id = p_item_id
       AND msn.wip_entity_id = p_wip_entity_id
       AND (   msn.intraoperation_step_type IS NULL
            OR msn.intraoperation_step_type <> 5
           )
       AND (   (msn.current_status IN (1, 6))
            OR (    l_restrict_serial_rcpt = 2
                AND msn.current_status = 4
                AND msn.last_txn_source_id = p_wip_entity_id
                AND NVL (msn.last_txn_source_type_id, -9999) = 5
               )
           );

    IF (l_ser_number_tbl.COUNT = 0)
    THEN
      IF (l_debug)
      THEN
        print_debug ('l_ser_number_tbl.COUNT' || l_ser_number_tbl.COUNT
                   , 'update_item_serial'
                    );
        print_debug ('returning..', 'update_item_serial');
      END IF;

      x_validation_status := 'Y';
      x_return_status := fnd_api.g_ret_sts_success;
      RETURN;
    END IF;

    IF ((p_to_item_id IS NOT NULL) AND (p_item_id <> p_to_item_id))
    THEN
      BEGIN
        BEGIN

          SELECT descriptive_flex_context_code
            INTO l_context_value_item
            FROM mtl_flex_context
           WHERE organization_id = p_org_id
             AND context_column_name = 'ITEM'
             AND descriptive_flexfield_name = 'Serial Attributes'
             AND context_column_value_id = p_item_id;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            l_context_value_item := NULL;
        END;

        BEGIN
          SELECT descriptive_flex_context_code
            INTO l_context_value_to_item
            FROM mtl_flex_context
           WHERE organization_id = p_org_id
             AND context_column_name = 'ITEM'
             AND descriptive_flexfield_name = 'Serial Attributes'
             AND context_column_value_id = p_to_item_id;
        EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
            l_context_value_to_item := NULL;
        END;
      EXCEPTION
        WHEN OTHERS
        THEN
          l_context_value_item := NULL;
          l_context_value_to_item := NULL;
      END;

      IF (   l_context_value_item IS NULL
          OR l_context_value_to_item IS NULL
          OR (l_context_value_item <> l_context_value_to_item)
         )
      THEN
        IF (l_debug)
        THEN
          print_debug
            ('Mismatch between source and dest Item attributes. Need to null out'
           , 'update_item_serial'
            );
        END IF;

        l_update_attr := TRUE;
      END IF;
    END IF;

    FOR i IN l_ser_number_tbl.FIRST .. l_ser_number_tbl.LAST
    LOOP
      IF (p_to_item_id IS NOT NULL AND p_to_item_id <> p_item_id)
      THEN
        IF (l_debug)
        THEN
          print_debug ('Calling is_serial_unique to check serial uniqueness'
                     , 'update_item_serial'
                      );
        END IF;

        l_ret :=
          inv_serial_number_pub.is_serial_unique (p_org_id
                                                , p_to_item_id
                                                , l_ser_number_tbl (i)
                                                , x_msg_data
                                                 );

        IF (l_debug)
        THEN
          print_debug ('is_serial_unique returned with l_ret ' || l_ret
                     , 'update_item_serial'
                      );
        END IF;

        IF (l_ret = 1)
        THEN
          IF (l_debug)
          THEN
            print_debug (   'serial_uniqueness failed for serial=> '
                         || l_ser_number_tbl (i)
                       , 'update_item_serial'
                        );
          END IF;

          x_validation_status := 'N';
          /* Bug:5162705.Modified the message name from INV_SERIAL_NOT_UNIQUE
              to INV_SERIAL_UNIQUENESS */
          /*Bug:5397573. Modified the following message from INV_SERIAL_UNIQUENESS
            to INV_JOB_SERIAL_UNIQUENESS. */
          fnd_message.set_name ('INV', 'INV_JOB_SERIAL_UNIQUENESS');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_update_attr) THEN
          BEGIN
            IF (l_debug)
            THEN
              print_debug ('Null out the attributes and update the MSN'
                         , 'update_item_serial'
                          );
            END IF;

            UPDATE mtl_serial_numbers
               SET inventory_item_id = NVL (p_to_item_id, inventory_item_id)
                 , wip_entity_id = NVL (p_to_wip_entity_id, wip_entity_id)
                 , operation_seq_num = p_to_operation_sequence
                 , intraoperation_step_type = p_intraoperation_step_type
                 , serial_attribute_category = NULL
                 , c_attribute1 = NULL
                 , c_attribute2 = NULL
                 , c_attribute3 = NULL
                 , c_attribute4 = NULL
                 , c_attribute5 = NULL
                 , c_attribute6 = NULL
                 , c_attribute7 = NULL
                 , c_attribute8 = NULL
                 , c_attribute9 = NULL
                 , c_attribute10 = NULL
                 , c_attribute11 = NULL
                 , c_attribute12 = NULL
                 , c_attribute13 = NULL
                 , c_attribute14 = NULL
                 , c_attribute15 = NULL
                 , c_attribute16 = NULL
                 , c_attribute17 = NULL
                 , c_attribute18 = NULL
                 , c_attribute19 = NULL
                 , c_attribute20 = NULL
                 , d_attribute1 = NULL
                 , d_attribute2 = NULL
                 , d_attribute3 = NULL
                 , d_attribute4 = NULL
                 , d_attribute5 = NULL
                 , d_attribute6 = NULL
                 , d_attribute7 = NULL
                 , d_attribute8 = NULL
                 , d_attribute9 = NULL
                 , d_attribute10 = NULL
                 , n_attribute1 = NULL
                 , n_attribute2 = NULL
                 , n_attribute3 = NULL
                 , n_attribute4 = NULL
                 , n_attribute5 = NULL
                 , n_attribute6 = NULL
                 , n_attribute7 = NULL
                 , n_attribute8 = NULL
                 , n_attribute9 = NULL
                 , n_attribute10 = NULL
                 , attribute_category = NULL
                 , attribute1 = NULL
                 , attribute2 = NULL
                 , attribute3 = NULL
                 , attribute4 = NULL
                 , attribute5 = NULL
                 , attribute6 = NULL
                 , attribute7 = NULL
                 , attribute8 = NULL
                 , attribute9 = NULL
                 , attribute10 = NULL
                 , attribute11 = NULL
                 , attribute12 = NULL
                 , attribute13 = NULL
                 , attribute14 = NULL
                 , attribute15 = NULL
                 , territory_code = NULL
                 , time_since_new = NULL
                 , cycles_since_new = NULL
                 , time_since_overhaul = NULL
                 , cycles_since_overhaul = NULL
                 , time_since_repair = NULL
                 , cycles_since_repair = NULL
                 , time_since_visit = NULL
                 , cycles_since_visit = NULL
                 , time_since_mark = NULL
                 , cycles_since_mark = NULL
                 , number_of_repairs = NULL
             WHERE inventory_item_id = p_item_id
               AND current_organization_id = p_org_id
               AND wip_entity_id = p_wip_entity_id
               AND serial_number = l_ser_number_tbl (i);

          EXCEPTION
            WHEN OTHERS
            THEN
              x_validation_status := 'N';
              RAISE rollback_serial_update;
          END;
        ELSE
          BEGIN
            IF (l_debug) THEN
              print_debug ('Update MSN when p_to_item_id <> p_item_id', 'update_item_serial');
            END IF;

            UPDATE mtl_serial_numbers
               SET inventory_item_id = NVL (p_to_item_id, inventory_item_id)
                 , wip_entity_id = NVL (p_to_wip_entity_id, wip_entity_id)
                 , operation_seq_num = p_to_operation_sequence
                 , intraoperation_step_type = p_intraoperation_step_type
             WHERE inventory_item_id = p_item_id
               AND current_organization_id = p_org_id
               AND wip_entity_id = p_wip_entity_id
               AND serial_number = l_ser_number_tbl (i);
            EXCEPTION
            WHEN OTHERS THEN
              x_validation_status := 'N';
              RAISE rollback_serial_update;
          END;
        END IF;   --END IF (l_update_attr)
      --Bug #5364039
      --Should update if p_to_item_id = p_item_id and other parameters change
      ELSE
        BEGIN
          IF (l_debug) THEN
            print_debug ('Update MSN when p_to_item_id = p_item_id', 'update_item_serial');
          END IF;

          UPDATE mtl_serial_numbers
             SET inventory_item_id = NVL (p_to_item_id, inventory_item_id)
               , wip_entity_id = NVL (p_to_wip_entity_id, wip_entity_id)
               , operation_seq_num = p_to_operation_sequence
               , intraoperation_step_type = p_intraoperation_step_type
           WHERE inventory_item_id = p_item_id
             AND current_organization_id = p_org_id
             AND wip_entity_id = p_wip_entity_id
             AND serial_number = l_ser_number_tbl (i);
        EXCEPTION
          WHEN OTHERS THEN
            x_validation_status := 'N';
            RAISE rollback_serial_update;
        END;
      END IF;   --END IF (p_to_item_id IS NOT NULL AND p_to_item_id <> p_item_id)
    END LOOP; --END FOR i IN l_ser_number_tbl.FIRST .. l_ser_number_tbl.LAST

    IF (l_debug) THEN
      print_debug ('All updations done, Exitting the procedure', 'update_item_serial');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
    WHEN rollback_serial_update
    THEN
      ROLLBACK TO initial_state_svpt;
    WHEN OTHERS
    THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_msg_pub.add_exc_msg (g_pkg_name, 'update_item_serial');
      END IF;

      fnd_msg_pub.count_and_get (p_count     => x_msg_count
                               , p_data      => x_msg_data);
      ROLLBACK TO initial_state_svpt;
  END;
END inv_lot_trx_validation_pub;

/

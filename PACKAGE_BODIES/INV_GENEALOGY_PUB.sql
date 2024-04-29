--------------------------------------------------------
--  DDL for Package Body INV_GENEALOGY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_GENEALOGY_PUB" AS
  /* $Header: INVPVCGB.pls 120.11.12000000.4 2007/01/26 20:12:46 mrana ship $ */

  /*-------------------------------------------------------------------------------+
   | This file contains the Genealogy API body. These APIs will be used            |
   | exclusively to Create Genealogy records                                       |
   | History:                                                                      |
   | May 10, 2000.       sthamman         Created package body.                    |
   | Aug 10, 2000.       mrana            Value for 4th column in insert           |
   |                                      object_genealogy should be l_parent_id   |
   +-------------------------------------------------------------------------------*/
  --
  --  FILENAME
  --
  --      INVPVCGB.pls
  --
  --  DESCRIPTION
  --      Body of package INV_genealogy_PUB
  --
  --  NOTES
  --
  --  HISTORY
  --     10-MAY-00    Created       sthamman
  --     23-May-00    Modified      sthamman
  --            Introduced the following parameters
  --            1. p_object_id
  --            2. p_inventory_item_id
  --            3. p_org_id
  --            4. p_parent_object_id
  --            5. p_parent_inventory_item_id
  --            6. p_parent_org_id
  --

/* Genealogy_object_types :
 * ----------------
 * 1 Lot
 * 2 Serial
 * 3 External
 * 4 Container
 * 5 Job
 *
 * Genealogy Type
 * ----------------
 * 1 Assembly
 * 2 Lot Split
 * 3 Lot merge
 * 4 Sublot
 * 5 Assets (used by EAM)
 *
 * Genealogy Origin
 * ----------------
 * 1 WIP
 * 2 Transaction
 * 3 Manual
 * */

  --  Global constant holding the package name
  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_genealogy_PUB';
  g_mod_name VARCHAR2(30) := NULL;
  --lg_fnd_validate_none CONSTANT NUMBER := 0;
  lg_fnd_g_false                VARCHAR2(1)  := FND_API.G_FALSE;
  lg_fnd_valid_level_full       NUMBER       := FND_API.G_VALID_LEVEL_FULL;

  lg_ret_sts_error              CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_error;
  lg_ret_sts_unexp_error        CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_unexp_error;
  lg_ret_sts_success            CONSTANT VARCHAR2(30) := fnd_api.g_ret_sts_success;

  lg_exc_error                  EXCEPTION  ; --fnd_api.g_exc_error;
  lg_exc_unexpected_error       EXCEPTION  ; --fnd_api.g_exc_unexpected_error;


-- R12 GEnealogy Enhancements :
-- Local prtocedure to validate input parameters passed to Insert-genealogy or
-- Update_genealogy. The reason for creating this is because both the procedures
-- have the same set of parameters and same validations

PROCEDURE parameter_validations(
    p_validation_level         IN            NUMBER   := gen_fnd_valid_level_full
  , p_object_type              IN            NUMBER
  , p_parent_object_type       IN            NUMBER
  , p_object_id                IN OUT NOCOPY NUMBER
  , p_object_number            IN            VARCHAR2
  , p_inventory_item_id        IN            NUMBER
  , p_org_id                   IN            NUMBER
  , p_parent_object_id         IN OUT NOCOPY NUMBER
  , p_parent_object_number     IN            VARCHAR2
  , p_parent_inventory_item_id IN            NUMBER
  , p_parent_org_id            IN            NUMBER
  , p_genealogy_origin         IN            NUMBER
  , p_genealogy_type           IN            NUMBER
  , p_start_date_active        IN            DATE
  , p_end_date_active          IN            DATE
  , p_origin_txn_id            IN            NUMBER
  , p_update_txn_id            IN            NUMBER
  , p_object_type2             IN OUT NOCOPY NUMBER
  , p_object_id2               IN OUT NOCOPY NUMBER
  , p_object_number2           IN            VARCHAR2
  , p_parent_object_type2      IN OUT NOCOPY NUMBER
  , p_parent_object_id2        IN OUT NOCOPY NUMBER
  , p_parent_object_number2    IN            VARCHAR2
  , p_child_lot_control_code   IN            NUMBER
  , p_parent_lot_control_code  IN            NUMBER
  , p_action                   IN            VARCHAR2
  , p_debug                    IN            NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2) ;


   PROCEDURE mydebug( p_msg        IN        VARCHAR2)
   IS
   BEGIN
       inv_log_util.trace( p_message => p_msg,
                           p_module  => g_pkg_name ,
                           p_level   => 9);

      --dbms_output.put_line( p_msg );
   END mydebug;

  /* The function recursively checks whether the parent is among
    the children of the given asset within the given dates.
    To do so, it exhaustively traverses down the tree with the
    given asset as its root node.  If it finds the parent, it
    returns a value of 1 and exits; otherwise it traverses
    until it reaches the leaf node. This function assumes that
    the existing data in the MOG table is valid and does not
    contain any loop.  Hence it does not check any asset that
    it has already traversed.  This is the main difference
    between this function and the previous select statement
    using a connect by clause.  This is a fix for bug # 2287872
  */

  FUNCTION genealogy_loop(
    object_id        IN            NUMBER
  , parent_object_id IN            NUMBER
  , start_date       IN            DATE
  , end_date         IN            DATE
  , object_table     IN OUT NOCOPY object_id_tbl_t
  )
    RETURN NUMBER AS
    l_dummy      NUMBER       := 0;
    i            NUMBER;
    l_dummy_char VARCHAR2(10) := NULL;
    l_object_id  NUMBER       := object_id;
    counter      NUMBER;
    l_start_date DATE;
    l_end_date   DATE;
    l_count      NUMBER;
    l_debug      NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- check if the parent asset is an immediate child of the given asset

    IF end_date IS NULL THEN
      BEGIN
        SELECT 1
          INTO l_dummy
          FROM DUAL
         WHERE parent_object_id IN (SELECT mog.object_id
                                      FROM mtl_object_genealogy mog
                                     WHERE (end_date_active IS NULL OR end_date_active >= start_date)
                                       AND parent_object_id = l_object_id
                                       AND genealogy_type = 5);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    ELSE
      BEGIN
        SELECT 1
          INTO l_dummy
          FROM DUAL
         WHERE parent_object_id IN (SELECT mog.object_id
                                      FROM mtl_object_genealogy mog
                                     WHERE (((start_date_active <= start_date)
                                             AND (end_date_active IS NULL
                                                  OR (end_date_active >= start_date)))
                                            OR ((start_date_active >= start_date)
                                                AND (start_date_active <= end_date)))
                                       AND parent_object_id = l_object_id
                                       AND genealogy_type = 5);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;

    -- if the parent asset is an immediate child of the given asset, return 1 and exit

    IF l_dummy = 1 THEN
      RETURN 1;
    ELSE
      -- otherwise recursively traverse along each of the child

      IF end_date IS NULL THEN
        FOR object_id_rec IN (SELECT object_id
                                   , start_date_active
                                   , end_date_active
                                FROM mtl_object_genealogy
                               WHERE genealogy_type = 5
                                 AND parent_object_id = l_object_id
                                 AND (end_date_active IS NULL OR end_date_active >= start_date))
        LOOP
          l_dummy_char  := 'N';
          i             := 1;

          WHILE (i <= object_table.COUNT
                 AND (object_id_rec.object_id <> object_table(i).object_id
                      OR object_id_rec.start_date_active <> object_table(i).start_date_active
                      OR object_id_rec.end_date_active <> object_table(i).end_date_active))
          LOOP
            i  := i + 1;
          END LOOP;

          IF i <= object_table.COUNT THEN
            l_dummy_char  := 'Y';
          END IF;

          IF l_dummy_char <> 'Y' THEN
            l_count  := object_table.COUNT + 1;

            SELECT object_id_rec.object_id
                 , object_id_rec.start_date_active
                 , object_id_rec.end_date_active
              INTO object_table(l_count).object_id
                 , object_table(l_count).start_date_active
                 , object_table(l_count).end_date_active
              FROM DUAL;

            IF (object_id_rec.start_date_active > end_date)
               OR (object_id_rec.end_date_active < start_date) THEN
              NULL;
            ELSE
              IF start_date > object_id_rec.start_date_active THEN
                l_start_date  := start_date;
              ELSE
                l_start_date  := object_id_rec.start_date_active;
              END IF;

              IF end_date > object_id_rec.end_date_active THEN
                l_end_date  := object_id_rec.end_date_active;
              ELSE
                l_end_date  := end_date;
              END IF;

              l_dummy  := genealogy_loop(object_id_rec.object_id, parent_object_id, l_start_date, l_end_date, object_table);

              IF l_dummy = 1 THEN
                RETURN 1;
              END IF;
            END IF;
          END IF;
        END LOOP;
      ELSE
        FOR object_id_rec IN (SELECT object_id
                                   , start_date_active
                                   , end_date_active
                                FROM mtl_object_genealogy
                               WHERE genealogy_type = 5
                                 AND parent_object_id = l_object_id
                                 AND (((start_date_active <= start_date)
                                       AND (end_date_active IS NULL
                                            OR (end_date_active >= start_date)))
                                      OR ((start_date_active >= start_date)
                                          AND (start_date_active <= end_date))))
        LOOP
          l_dummy_char  := 'N';
          i             := 1;
          l_count       := object_table.COUNT;

          WHILE (i <= l_count
                 AND (object_id_rec.object_id <> object_table(i).object_id
                      OR object_id_rec.start_date_active <> object_table(i).start_date_active
                      OR object_id_rec.end_date_active <> object_table(i).end_date_active))
          LOOP
            i  := i + 1;
          END LOOP;

          IF i <= l_count THEN
            l_dummy_char  := 'Y';
          END IF;

          IF l_dummy_char <> 'Y' THEN
            SELECT object_id_rec.object_id
                 , object_id_rec.start_date_active
                 , object_id_rec.end_date_active
              INTO object_table(l_count + 1).object_id
                 , object_table(l_count + 1).start_date_active
                 , object_table(l_count + 1).end_date_active
              FROM DUAL;

            IF (object_id_rec.start_date_active > end_date)
               OR (object_id_rec.end_date_active < start_date) THEN
              NULL;
            ELSE
              IF start_date > object_id_rec.start_date_active THEN
                l_start_date  := start_date;
              ELSE
                l_start_date  := object_id_rec.start_date_active;
              END IF;

              IF end_date > object_id_rec.end_date_active THEN
                l_end_date  := object_id_rec.end_date_active;
              ELSE
                l_end_date  := end_date;
              END IF;

              l_dummy  := genealogy_loop(object_id_rec.object_id, parent_object_id, l_start_date, l_end_date, object_table);

              IF l_dummy = 1 THEN
                RETURN 1;
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END IF;

    RETURN 0;
  END;

  PROCEDURE insert_genealogy(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := gen_fnd_g_false
  , p_commit                   IN            VARCHAR2 := gen_fnd_g_false
  , p_validation_level         IN            NUMBER   := gen_fnd_valid_level_full
  , p_object_type              IN            NUMBER
  , p_parent_object_type       IN            NUMBER   := NULL
  , p_object_id                IN            NUMBER   := NULL
  , p_object_number            IN            VARCHAR2 := NULL
  , p_inventory_item_id        IN            NUMBER   := NULL
  , p_org_id                   IN            NUMBER   := NULL
  , p_parent_object_id         IN            NUMBER   := NULL
  , p_parent_object_number     IN            VARCHAR2 := NULL
  , p_parent_inventory_item_id IN            NUMBER   := NULL
  , p_parent_org_id            IN            NUMBER   := NULL
  , p_genealogy_origin         IN            NUMBER   := NULL
  , p_genealogy_type           IN            NUMBER   := NULL
  , p_start_date_active        IN            DATE     := SYSDATE
  , p_end_date_active          IN            DATE     := NULL
  , p_origin_txn_id            IN            NUMBER   := NULL
  , p_update_txn_id            IN            NUMBER   := NULL
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  , p_object_type2             IN            NUMBER   := NULL    -- R12 Genealogy Enhancements
  , p_object_id2               IN            NUMBER   := NULL    -- R12 Genealogy Enhancements
  , p_object_number2           IN            VARCHAR2 := NULL    -- R12 Genealogy Enhancements
  , p_parent_object_type2      IN            NUMBER   := NULL    -- R12 Genealogy Enhancements
  , p_parent_object_id2        IN            NUMBER   := NULL    -- R12 Genealogy Enhancements
  , p_parent_object_number2    IN            VARCHAR2 := NULL    -- R12 Genealogy Enhancements
  , p_child_lot_control_code   IN            NUMBER   := NULL    -- R12 Genealogy Enhancements
  , p_parent_lot_control_code  IN            NUMBER   := NULL    -- R12 Genealogy Enhancements
  ) IS
    l_api_version     CONSTANT NUMBER          := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)    := 'insert_genealogy';
    l_dummy                    NUMBER := 0;
    l_dummy_char               VARCHAR2(30);
    l_dummy_num                NUMBER  := 0;
    l_dummy_date               DATE;
    l_dummy_date2              DATE;
    l_org_id                   NUMBER;
    retval                     NUMBER;
    l_parent_org_id            NUMBER;
    l_object_id                NUMBER;
    l_parent_object_id         NUMBER;
    l_object_id2               NUMBER;
    l_parent_object_id2        NUMBER;
    l_object_type2             NUMBER;
    l_parent_object_type2      NUMBER;
    l_parent_object_type       NUMBER;
    l_parent_inventory_item_id NUMBER;
    l_inventory_item_id        NUMBER;
    l_child_item_type          NUMBER;
    l_parent_item_type         NUMBER;
    l_object_table             object_id_tbl_t;
    l_serial_number            VARCHAR2(30);
    l_instance_number            VARCHAR2(30);
    l_parent_instance_number            VARCHAR2(30);
    l_debug                    NUMBER   :=1 ; --       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_invalid_field_msg        VARCHAR2(50);
    l_invalid_comb_msg         VARCHAR2(150);
    l_child_lot_control_code   NUMBER;  -- R12
    l_parent_lot_control_code  NUMBER;  -- R12
    l_action                   VARCHAR2(10);
    l_end_date_active          DATE;
    l_return_status            VARCHAR2(10);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(4000);
  BEGIN
    -- Standard Start of API savepoint
    x_return_status  := lg_ret_sts_success;
    SAVEPOINT save_insert_genealogy;
    g_mod_name := 'Insert_Genealogy';

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE lg_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       mydebug('in procedure ...: '  || g_mod_name  );
       mydebug('p_api_version: '  || p_api_version  );
       mydebug('p_init_msg_list: '  || p_init_msg_list  );
       mydebug('p_commit: '  || p_commit  );
       mydebug('p_validation_level: '  || p_validation_level  );
       mydebug('p_object_type: '  || p_object_type  );
       mydebug('p_parent_object_type: '  || p_parent_object_type  );
       mydebug('p_object_id: '  || p_object_id  );
       mydebug('p_object_number: '  || p_object_number  );
       mydebug('p_inventory_item_id: '   || p_inventory_item_id   );
       mydebug('p_org_id: '  || p_org_id  );
       mydebug('p_parent_object_id: '  || p_parent_object_id  );
       mydebug('p_parent_object_number: '  || p_parent_object_number  );
       mydebug('p_parent_inventory_item_id: '  || p_parent_inventory_item_id  );
       mydebug('p_parent_org_id: '  || p_parent_org_id  );
       mydebug('p_genealogy_origin: '  || p_genealogy_origin  );
       mydebug('p_genealogy_type: '  || p_genealogy_type  );
       mydebug('p_start_date_active: '  || p_start_date_active  );
       mydebug('p_end_date_active: '  || p_end_date_active  );
       mydebug('p_origin_txn_id: '  || p_origin_txn_id  );
       mydebug('p_update_txn_id: '   || p_update_txn_id   );
       mydebug('p_object_type2: '  || p_object_type2  );
       mydebug('p_object_id2: '  || p_object_id2  );
       mydebug('p_object_number2: '  || p_object_number2  );
       mydebug('p_parent_object_type2: '  || p_parent_object_type2  );
       mydebug('p_parent_object_id2: '   || p_parent_object_id2   );
       mydebug('p_parent_object_number2: '  || p_parent_object_number2  );
       mydebug('p_child_lot_control_code: '  || p_child_lot_control_code  );
       mydebug('p_parent_lot_control_code: '  || p_parent_lot_control_code  );
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    IF p_parent_object_type IS NULL THEN
         l_parent_object_type  := p_object_type;
    ELSE
         l_parent_object_type  := p_parent_object_type;
    END IF;

    IF p_parent_org_id IS NULL THEN
         l_parent_org_id  := p_org_id;
    ELSE
         l_parent_org_id  := p_parent_org_id;
    END IF;

    l_action  := 'INSERT';

    l_object_id2 := p_object_id2;
    l_parent_object_id2 := p_parent_object_id2;
    l_object_type2 := p_object_type2;
    l_parent_object_type2 := p_parent_object_type2;
    l_object_id := p_object_id;
    l_parent_object_id := p_parent_object_id;

    IF (l_debug = 1) THEN
       mydebug('l_parent_object_type: '  || l_parent_object_type  );
       mydebug('l_parent_org_id: '  || l_parent_org_id  );
       mydebug('l_object_id2: '  || l_object_id2  );
       mydebug('l_parent_object_id2: '  || l_parent_object_id2  );
       mydebug('l_object_type2w: '  || l_object_type2  );
       mydebug('l_parent_object_type2: '  || l_parent_object_type2  );
       mydebug('l_object_id: '  || l_object_id  );
       mydebug('jel_parent_object_id: '  || l_parent_object_id  );
    END IF;


    -- R12 Genealogy Enhancements : Moved all the validations to the new procedure parameter_validations
    -- Check for the parameters
      parameter_validations(
          p_validation_level         => p_validation_level
        , p_object_type              => p_object_type
        , p_parent_object_type       => l_parent_object_type
        , p_object_id                => l_object_id
        , p_object_number            => p_object_number
        , p_inventory_item_id        => p_inventory_item_id
        , p_org_id                   => p_org_id
        , p_parent_object_id         => l_parent_object_id
        , p_parent_object_number     => p_parent_object_number
        , p_parent_inventory_item_id => p_parent_inventory_item_id
        , p_parent_org_id            => l_parent_org_id
        , p_genealogy_origin         => p_genealogy_origin
        , p_genealogy_type           => p_genealogy_type
        , p_start_date_active        => p_start_date_active
        , p_end_date_active          => p_end_date_active
        , p_origin_txn_id            => p_origin_txn_id
        , p_update_txn_id            => p_update_txn_id
        , p_object_type2             => l_object_type2
        , p_object_id2               => l_object_id2
        , p_object_number2           => p_object_number2
        , p_parent_object_type2      => l_parent_object_type2
        , p_parent_object_id2        => l_parent_object_id2
        , p_parent_object_number2    => p_parent_object_number2
        , p_child_lot_control_code   => p_child_lot_control_code
        , p_parent_lot_control_code  => p_parent_lot_control_code
        , p_action                   => l_action
        , p_debug                    => l_debug
        , x_return_status            => x_return_status
        , x_msg_count                => x_msg_count
        , x_msg_data                 => x_msg_data);

    g_mod_name := 'Insert_Genealogy';

          IF (l_debug = 1) THEN mydebug('x_return_status from parameter_validations API: ' || x_return_status); END IF;

          IF x_return_status = lg_ret_sts_error
          THEN
             IF (l_debug = 1) THEN
                 mydebug('{{ If any of the parameter validations failed, then raise  ' ||
                          'an expected exception now..before inserting into genealogy }}' );
             END IF;
             RAISE lg_exc_error;
          END IF;
          IF x_return_status = lg_ret_sts_unexp_error
          THEN
             IF (l_debug = 1) THEN mydebug('{{ If any of the parameter validations failed, then raise  ' ||
                                            'an unexpected exception now..before inserting into genealogy }}');
             END IF;
             RAISE lg_exc_unexpected_error;
          END IF;


    IF (l_debug = 1) THEN
       mydebug('After calling parameter validations, check the value of IN OUT parameters ' );
       mydebug('l_object_id                := ' || l_object_id );
       mydebug('l_parent_object_id         := ' || l_parent_object_id);
       mydebug('l_object_type2             := ' || l_object_type2);
       mydebug('l_object_id2               := ' || l_object_id2);
       mydebug('l_parent_object_type2      := ' || l_parent_object_type2) ;
       mydebug('l_parent_object_id2        := ' || l_parent_object_id2) ;
    END IF;

    -- Eam Validations Starts here
    -- if EAM data, do EAM genealogy validations
    IF (p_genealogy_type = 5) THEN
       IF (l_debug = 1) THEN mydebug(' Start of EAM Validations'); END IF;
      -- validate that the parent and child are different objects
      IF l_object_id = l_parent_object_id THEN
        fnd_message.set_name('INV', 'INV_EAM_GENEALOGY_SAME_CH_PAR');
        fnd_msg_pub.ADD;
        RAISE lg_exc_error;
      END IF;

      -- determine the child org
      IF p_org_id IS NOT NULL THEN
        l_org_id  := p_org_id;
      ELSE
        SELECT msn.current_organization_id
          INTO l_org_id
          FROM mtl_serial_numbers msn
         WHERE msn.gen_object_id = l_object_id;
      END IF;

      -- determine the parent org
      IF p_parent_org_id IS NOT NULL THEN
        l_parent_org_id  := p_parent_org_id;
      ELSE
        SELECT msn.current_organization_id
          INTO l_parent_org_id
          FROM mtl_serial_numbers msn
         WHERE msn.gen_object_id = l_parent_object_id;
      END IF;

      -- validate that the start date is not null
      IF p_start_date_active IS NULL THEN
        fnd_message.set_name('INV', 'INV_EAM_GEN_NULL_START_DATE');
        fnd_msg_pub.ADD;
        RAISE lg_exc_error;
      END IF;

      -- validate that the end date, if not null, is greater than the start date
      IF p_end_date_active IS NOT NULL THEN
        IF p_start_date_active > p_end_date_active THEN
          fnd_message.set_name('INV', 'INV_EAM_START_END_DATE_INVALID');
          fnd_message.set_token('ENTITY1', TO_CHAR(p_start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
          fnd_message.set_token('ENTITY2', TO_CHAR(p_end_date_active, 'DD-MON-YYYY HH24:MI:SS'));
          fnd_msg_pub.ADD;
          RAISE lg_exc_error;
        END IF;
      END IF;

      -- ***EAM change to allow rebuildables to be parents***
            -- check to see if the parent object is a rebuildable.
            -- If so it cannot have an asset child


      IF p_parent_inventory_item_id IS NOT NULL THEN
        l_parent_inventory_item_id  := p_parent_inventory_item_id;
      ELSE
        SELECT msn.inventory_item_id
          INTO l_parent_inventory_item_id
          FROM mtl_serial_numbers msn
         WHERE msn.gen_object_id = l_parent_object_id;
      END IF;

      SELECT msi.eam_item_type
        INTO l_parent_item_type
        FROM mtl_system_items msi
       WHERE msi.inventory_item_id = l_parent_inventory_item_id
         AND msi.organization_id = l_parent_org_id;

      IF l_parent_item_type IS NULL THEN
        fnd_message.set_name('INV', 'INV_EAM_PARENT_ITEM_TYPE');
        fnd_msg_pub.ADD;
        RAISE lg_exc_error;
      END IF;

      IF p_inventory_item_id IS NOT NULL THEN
        l_inventory_item_id  := p_inventory_item_id;
      ELSE
        SELECT msn.inventory_item_id
          INTO l_inventory_item_id
          FROM mtl_serial_numbers msn
         WHERE msn.gen_object_id = l_object_id;
      END IF;

      SELECT msi.eam_item_type
        INTO l_child_item_type
        FROM mtl_system_items msi
       WHERE msi.inventory_item_id = l_inventory_item_id
         AND msi.organization_id = l_org_id;

      IF l_child_item_type IS NULL THEN
        fnd_message.set_name('INV', 'INV_EAM_CHILD_ITEM_TYPE');
        fnd_msg_pub.ADD;
        RAISE lg_exc_error;
      END IF;


      /*  Start  R12 changes made by Himal -- EAM group
      -- rebuildables cannot be parents of assets
      IF ((l_parent_item_type = 3)
          AND (l_child_item_type = 1)
         ) THEN
        fnd_message.set_name('INV', 'INV_EAM_ASSET_REBUILD_PARENT');
        fnd_msg_pub.ADD;
        RAISE lg_exc_error;
      END IF;

      -- *** End of eam change to allow parent rebuildables ***

      END --R12 changes made by Himal -- EAM group */

      -- validate origin transaction id with the genealogy_origin
      -- If origin transaction id is null then genealogy origin
      -- should show that it was a manual entry
      IF p_origin_txn_id IS NULL THEN
        IF p_genealogy_origin <> 3 THEN
          fnd_message.set_name('INV', 'INV_FIELD_INVALID');
          fnd_message.set_token('ENTITY1', 'p_genealogy_origin');
          fnd_msg_pub.ADD;
          RAISE lg_exc_error;
        END IF;
      END IF;

      SELECT serial_number
        INTO l_serial_number
        FROM mtl_serial_numbers
       WHERE gen_object_id = l_object_id;

      DECLARE
        CURSOR genealogy_entry_cur IS
          SELECT mog.start_date_active start_date_active
               , mog.end_date_active end_date_active
               , msn.serial_number parent_serial_number
	       , msn.inventory_item_id parent_inventory_item_id
            FROM mtl_object_genealogy mog, mtl_serial_numbers msn
           WHERE mog.object_id = l_object_id
             AND msn.gen_object_id = mog.parent_object_id
             AND mog.genealogy_type = 5;
      BEGIN
        FOR i IN genealogy_entry_cur LOOP
          IF i.end_date_active IS NOT NULL THEN
            IF p_end_date_active IS NOT NULL THEN
              IF ((p_start_date_active <= i.start_date_active)
                  AND (p_end_date_active >= i.start_date_active)
                 )
                 OR ((p_start_date_active >= i.start_date_active)
                     AND (p_end_date_active <= i.end_date_active)
                    )
                 OR ((p_start_date_active <= i.start_date_active)
                     AND (p_end_date_active >= i.end_date_active)
                    )
                 OR ((p_start_date_active <= i.end_date_active)
                     AND (p_end_date_active >= i.end_date_active)
                    ) THEN


      		begin
			select instance_number into l_instance_number
			from csi_item_instances
			where serial_number = l_serial_number
			and inventory_item_id = l_inventory_item_id
                        and last_vld_organization_id = l_org_id;

			select instance_number into l_parent_instance_number
			from csi_item_instances
			where serial_number = i.parent_serial_number
			and inventory_item_id = i.parent_inventory_item_id
                        and last_vld_organization_id = l_parent_org_id;

		end;

                fnd_message.set_name('INV', 'INV_EAM_DATE_OVERLAP');
                fnd_message.set_token('ENTITY1', l_instance_number);
                fnd_message.set_token('ENTITY2', l_parent_instance_number);
                fnd_message.set_token('ENTITY3', TO_CHAR(i.start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
                fnd_message.set_token('ENTITY4', TO_CHAR(i.end_date_active, 'DD-MON-YYYY HH24:MI:SS'));
                fnd_message.set_token('ENTITY5', TO_CHAR(p_start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
                fnd_message.set_token('ENTITY6', TO_CHAR(p_end_date_active, 'DD-MON-YYYY HH24:MI:SS'));
                fnd_msg_pub.ADD;
                RAISE lg_exc_error;
              END IF;
            ELSE
              IF (p_start_date_active <= i.end_date_active) THEN

      		begin
			select instance_number into l_instance_number
			from csi_item_instances
			where serial_number = l_serial_number
			and inventory_item_id = l_inventory_item_id
                        and last_vld_organization_id = l_org_id;

			select instance_number into l_parent_instance_number
			from csi_item_instances
			where serial_number = i.parent_serial_number
			and inventory_item_id = i.parent_inventory_item_id
                        and last_vld_organization_id = l_parent_org_id;

		end;

                fnd_message.set_name('INV', 'INV_EAM_DATE_OVERLAP2');
                fnd_message.set_token('ENTITY1', l_instance_number);
                fnd_message.set_token('ENTITY2', l_parent_instance_number);
                fnd_message.set_token('ENTITY3', TO_CHAR(i.start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
                fnd_message.set_token('ENTITY4', TO_CHAR(i.end_date_active, 'DD-MON-YYYY HH24:MI:SS'));
                fnd_message.set_token('ENTITY5', TO_CHAR(p_start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
                fnd_msg_pub.ADD;
                RAISE lg_exc_error;
              END IF;
            END IF;
          ELSE
            IF p_end_date_active IS NULL THEN

      		begin
			select instance_number into l_instance_number
			from csi_item_instances
			where serial_number = l_serial_number
			and inventory_item_id = l_inventory_item_id
                        and last_vld_organization_id = l_org_id;

			select instance_number into l_parent_instance_number
			from csi_item_instances
			where serial_number = i.parent_serial_number
			and inventory_item_id = i.parent_inventory_item_id
                        and last_vld_organization_id = l_parent_org_id;

		end;

              fnd_message.set_name('INV', 'INV_EAM_DATE_OVERLAP3');
                fnd_message.set_token('ENTITY1', l_instance_number);
                fnd_message.set_token('ENTITY2', l_parent_instance_number);
              fnd_message.set_token('ENTITY3', TO_CHAR(i.start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
              fnd_message.set_token('ENTITY4', TO_CHAR(p_start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
              fnd_msg_pub.ADD;
              RAISE lg_exc_error;
            ELSIF (p_start_date_active >= i.start_date_active)
                  OR (p_end_date_active >= i.start_date_active) THEN

      		begin
			select instance_number into l_instance_number
			from csi_item_instances
			where serial_number = l_serial_number
			and inventory_item_id = l_inventory_item_id
                        and last_vld_organization_id = l_org_id;

			select instance_number into l_parent_instance_number
			from csi_item_instances
			where serial_number = i.parent_serial_number
			and inventory_item_id = i.parent_inventory_item_id
                        and last_vld_organization_id = l_parent_org_id;

		end;

              fnd_message.set_name('INV', 'INV_EAM_DATE_OVERLAP1');
                fnd_message.set_token('ENTITY1', l_instance_number);
                fnd_message.set_token('ENTITY2', l_parent_instance_number);
              fnd_message.set_token('ENTITY3', TO_CHAR(i.start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
              fnd_message.set_token('ENTITY4', TO_CHAR(p_start_date_active, 'DD-MON-YYYY HH24:MI:SS'));
              fnd_message.set_token('ENTITY5', TO_CHAR(p_end_date_active, 'DD-MON-YYYY HH24:MI:SS'));
              fnd_msg_pub.ADD;
              RAISE lg_exc_error;
            END IF;
          END IF;
        END LOOP;
      END;

      -- check for genealogy loops i.e. the parent object is not a child of the object
      DECLARE
        l_parent_serial_number VARCHAR2(30);
      BEGIN
        SELECT l_object_id
          INTO l_object_table(1).object_id
          FROM DUAL;

        -- call to the function that checks for the genealogy loop
        retval  := genealogy_loop(l_object_id, l_parent_object_id,
                                  p_start_date_active, p_end_date_active, l_object_table);

        IF retval = 1 THEN
          SELECT serial_number, inventory_item_id
            INTO l_parent_serial_number, l_parent_inventory_item_id
            FROM mtl_serial_numbers msn
           WHERE gen_object_id = l_parent_object_id;

      		begin
			select instance_number into l_instance_number
			from csi_item_instances
			where serial_number = l_serial_number
			and inventory_item_id = l_inventory_item_id
                        and last_vld_organization_id = l_org_id;

			select instance_number into l_parent_instance_number
			from csi_item_instances
			where serial_number = l_parent_serial_number
			and inventory_item_id = l_parent_inventory_item_id
                        and last_vld_organization_id = l_parent_org_id;

		end;

          fnd_message.set_name('INV', 'INV_EAM_GENEALOGY_LOOP');
          fnd_message.set_token('ENTITY1', l_parent_instance_number);
          fnd_message.set_token('ENTITY2', l_instance_number);
          fnd_msg_pub.ADD;
          RAISE lg_exc_error;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
      IF (l_debug = 1) THEN mydebug(' After EAM Validations'); END IF;
    ELSE
       IF (l_debug = 1) THEN mydebug(' Not EAM Type'); END IF;
    END IF;

    -- EAM Validations Ends here


    /* Fix bug 2138294, in EAM, object is not inserted into genealogy table
       Reason: l_dummy = 0 because there is existing parent/child relationship
       Fix: For EAM, it is allowed to have existing parent/child relationship,
        Added 'AND GENEALOGY_TYPE <> 5' to not include genealogy_type of 5 (Assets) */

    /* bug 2712800 The genealogy was not getting built when the serial number
       is completed the second time. Add the condition 'end_date_active is null'
       so that the genealogy is built if the end_date_active is already marked.
       For serials, end_date_active is marked with the sysdate once the serial
       number is returned (Serial-Tracking in WIP)*/

    l_dummy := -999;

    -- R12 Genealogy Enhancements:
    -- If second set of object details exist then we should check the existence
    -- of relationship using first set + second set
       IF l_object_id2 IS NULL AND l_parent_object_id2 IS NULL  THEN
          IF (l_debug = 1) THEN
             mydebug('{{- Genealogy is not between lot+serial controlled items }}');
          END IF;
          SELECT COUNT(*)
            INTO l_dummy
            FROM mtl_object_genealogy
           WHERE object_id = l_object_id
             AND object_id2 IS NULL  -- added this for lot+serial controlled items
             AND parent_object_id = l_parent_object_id
             AND parent_object_id2 IS NULL
             AND end_date_active IS NULL
             AND genealogy_type <> 5;
       ELSIF l_object_id2 IS NULL AND l_parent_object_id2 IS NOT NULL  THEN
          IF (l_debug = 1) THEN
           mydebug('{{- Genealogy is between non lot+serial child and lot+serial parent}}');
          END IF;
          SELECT COUNT(*)
            INTO l_dummy
            FROM mtl_object_genealogy
           WHERE object_id = l_object_id
             AND object_id2 IS NULL  -- added this for lot+serial controlled items
             AND parent_object_id = l_parent_object_id
             AND parent_object_id2 = l_parent_object_id2
             AND end_date_active IS NULL
             AND genealogy_type <> 5;
       ELSIF l_object_id2 IS NOT NULL AND l_parent_object_id2 IS NULL  THEN
          IF (l_debug = 1) THEN
           mydebug(' {{- Genealogy is between lot+serial child and non lot+serial parent }}');
          END IF;
          SELECT COUNT(*)
            INTO l_dummy
            FROM mtl_object_genealogy
           WHERE object_id = l_object_id
             AND object_id2 = l_object_id2  -- added this for lot+serial controlled items
             AND parent_object_id = l_parent_object_id
             AND parent_object_id2 IS NULL
             AND end_date_active IS NULL
             AND genealogy_type <> 5;
       ELSIF l_object_id2 IS NOT NULL AND l_parent_object_id2 IS NOT NULL  THEN
           IF (l_debug = 1) THEN
           mydebug(' {{- Genealogy is between lot+serial child and lot+serial parent }}');
          END IF;
          SELECT COUNT(*)
            INTO l_dummy
            FROM mtl_object_genealogy
           WHERE object_id = l_object_id
             AND object_id2 = l_object_id2  -- added this for lot+serial controlled items
             AND parent_object_id = l_parent_object_id
             AND parent_object_id2 = l_parent_object_id2
             AND end_date_active IS NULL
             AND genealogy_type <> 5;
       END IF ;

    IF (l_debug = 1) THEN
       mydebug('l_dummy(count of relatioships): '   || l_dummy  );
    END IF ;

    IF (l_dummy = 0)  THEN
        -- No need of this condition  AND (l_object_id <> l_parent_object_id)
           IF (l_debug = 1) THEN
              mydebug('{{- Only if the relationship does not exist that a new record is }}' ||
                                '{{  inserted in mtl_object_genealogy for the given l_object_id, l_object_id2 }} ' ||
                                '{{  and  l_parent_object_id, l_parent_object_id2  combination }}' );
              mydebug('{{- If the relationship is between lot+serial controlled item, make sure }}' ||
                                     '{{  that columns with 2 as suffix are also populated in the table }}'
                                     );
           END IF ;
           INSERT INTO mtl_object_genealogy
                  (
                  object_id
                , object_type
                , object_id2                    -- R12 Genealogy Enhancements
                , object_type2                  -- R12 Genealogy Enhancements
                , parent_object_type
                , parent_object_id
                , parent_object_type2           -- R12 Genealogy Enhancements
                , parent_object_id2             -- R12 Genealogy Enhancements
                , last_update_date
                , last_updated_by
                , creation_date
                , created_by
                , start_date_active
                , end_date_active
                , genealogy_origin
                , origin_txn_id
                , update_txn_id
                , genealogy_type
                , last_update_login
                , attribute_category
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
                , request_id
                , program_application_id
                , program_id
                , program_update_date
                  )
           VALUES (
                  l_object_id
                , p_object_type
                , l_object_id2                   -- R12Genealogy Enhancements
                , l_object_type2                 -- R12Genealogy Enhancements
                , p_parent_object_type
                , l_parent_object_id
                , l_parent_object_type2          -- R12Genealogy Enhancements
                , l_parent_object_id2            -- R12Genealogy Enhancements
                , SYSDATE
                , -1
                , SYSDATE + 10
                , fnd_global.user_id
                , p_start_date_active
                , p_end_date_active
                , p_genealogy_origin
                , p_origin_txn_id
                , p_update_txn_id
                , p_genealogy_type
                , -1
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , NULL
                , fnd_global.conc_request_id
                , fnd_global.prog_appl_id
                , fnd_global.conc_program_id
                , SYSDATE
                  );

         IF (l_debug = 1) THEN mydebug( 'Inserted a New Record ' ); END IF;

         --End of API body.
         -- Standard check of p_commit.
         IF fnd_api.to_boolean(p_commit) THEN
           COMMIT WORK;
           IF (l_debug = 1) THEN mydebug( 'Commit work' ); END IF;
         END IF;

         -- Standard call to get message count and if count is 1, get message info.
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    ELSE
         IF (l_debug = 1) THEN mydebug( 'Record Already present ' ); END IF;
    END IF;
    mydebug('Out of  procedure ...: '  || g_mod_name  );
  EXCEPTION
    WHEN lg_exc_error THEN
      IF (l_debug = 1) THEN
        mydebug('exception G_EXC_ERROR'|| x_msg_data);
      END IF;

      ROLLBACK TO apiinsert_genealogy_apipub;
      x_return_status  := lg_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN lg_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
        mydebug('exception G_UNEXC_ERROR'|| x_msg_data);
      END IF;

      ROLLBACK TO apiinsert_genealogy_apipub;
      x_return_status  := lg_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('exception WHEN OTHERS'|| x_msg_data);
      END IF;

      ROLLBACK TO apiinsert_genealogy_apipub;
      x_return_status  := lg_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
  END insert_genealogy;

  PROCEDURE update_genealogy(
    p_api_version       IN            NUMBER
  , p_init_msg_list     IN            VARCHAR2 := gen_fnd_g_false
  , p_commit            IN            VARCHAR2 := gen_fnd_g_false
  , p_validation_level  IN            NUMBER := gen_fnd_valid_level_full
  , p_object_type       IN            NUMBER
  , p_object_id         IN            NUMBER := NULL
  , p_object_number     IN            VARCHAR2 := NULL
  , p_inventory_item_id IN            NUMBER := NULL
  , p_org_id            IN            NUMBER := NULL
  , p_genealogy_origin  IN            NUMBER := NULL
  , p_genealogy_type    IN            NUMBER := NULL
  , p_end_date_active   IN            DATE := NULL
  , p_update_txn_id     IN            NUMBER := NULL
  , x_return_status     OUT NOCOPY    VARCHAR2
  , x_msg_count         OUT NOCOPY    NUMBER
  , x_msg_data          OUT NOCOPY    VARCHAR2
  ) IS
    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'update_genealogy';
    l_dummy                NUMBER;
    l_dummy_char           VARCHAR2(30);
    l_dummy_date           DATE;
    l_object_id            NUMBER;
    l_parent_object_id     NUMBER;
    l_parent_object_type   NUMBER;
    l_debug                NUMBER   :=1 ; --    := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT update_genealogy_pub;

    g_mod_name := 'Update Genealogy';

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE lg_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status  := lg_ret_sts_success;

        -- API body
    -- Check for the mandatory parameters
    IF p_object_type IS NULL THEN
      fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
      fnd_message.set_token('ATTRIBUTE', 'p_object_type');
      fnd_msg_pub.ADD;
      RAISE lg_exc_error;
    END IF;

    IF p_object_id IS NULL THEN
      IF p_object_number IS NULL
         OR p_inventory_item_id IS NULL
         OR p_org_id IS NULL THEN
        IF p_object_number IS NULL THEN
          fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
          fnd_message.set_token('ATTRIBUTE', 'p_object_number');
          fnd_msg_pub.ADD;
        END IF;

        IF p_inventory_item_id IS NULL THEN
          fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
          fnd_message.set_token('ATTRIBUTE', 'p_inventory_item_id');
          fnd_msg_pub.ADD;
        END IF;

        IF p_org_id IS NULL THEN
          fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
          fnd_message.set_token('ATTRIBUTE', 'p_org_id');
          fnd_msg_pub.ADD;
        END IF;

        RAISE lg_exc_error;
      END IF;
    END IF;

    -- Object type can be either 1 (lot number) or 2 (serial Number).
    -- If invalid return an error.
    IF p_object_type < 1
       OR p_object_type > 2 THEN
      fnd_message.set_name('INV', 'INV_FIELD_INVALID');
      fnd_message.set_token('ENTITY1', 'p_object_type');
      fnd_msg_pub.ADD;
      RAISE lg_exc_error;
    END IF;

    -- Validate the existence of object number in MTL_SERIAL_NUMBERS
    -- or MTL_LOT_NUMBERS depending on the object type.
    -- If object number is not found return an error.
    IF p_object_type = 1 THEN
      IF p_object_id IS NOT NULL THEN
        SELECT COUNT(*)
          INTO l_dummy
          FROM mtl_lot_numbers
         WHERE gen_object_id = p_object_id;

        IF l_dummy = 0 THEN
          fnd_message.set_name('INV', 'INV_FIELD_INVALID');
          fnd_message.set_token('ENTITY1', 'p_object_id');
          fnd_msg_pub.ADD;
          RAISE lg_exc_error;
        END IF;

        l_object_id  := p_object_id;
      ELSE
        BEGIN
          SELECT gen_object_id
            INTO l_object_id
            FROM mtl_lot_numbers
           WHERE lot_number = p_object_number
             AND inventory_item_id = p_inventory_item_id
             AND organization_id = p_org_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
            fnd_message.set_token('ENTITY1', 'p_object_number, p_inventory_item_id and p_org_id combination');
            fnd_msg_pub.ADD;
            RAISE lg_exc_error;
        END;
      END IF;
    ELSIF p_object_type = 2 THEN
      IF p_object_id IS NOT NULL THEN
        SELECT COUNT(*)
          INTO l_dummy
          FROM mtl_serial_numbers
         WHERE gen_object_id = p_object_id;

        IF l_dummy = 0 THEN
          fnd_message.set_name('INV', 'INV_FIELD_INVALID');
          fnd_message.set_token('ENTITY1', 'p_object_id');
          fnd_msg_pub.ADD;
          RAISE lg_exc_error;
        END IF;

        l_object_id  := p_object_id;
      ELSE
        BEGIN
          SELECT gen_object_id
            INTO l_object_id
            FROM mtl_serial_numbers
           WHERE serial_number = p_object_number
             AND inventory_item_id = p_inventory_item_id
             AND current_organization_id = p_org_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
            fnd_message.set_token('ENTITY1', 'p_object_number, p_inventory_item_id and p_org_id combination');
            fnd_msg_pub.ADD;
            RAISE lg_exc_error;
        END;
      END IF;
    END IF;

    IF p_genealogy_origin IS NOT NULL THEN
      SELECT COUNT(*)
        INTO l_dummy
        FROM mfg_lookups
       WHERE lookup_type = 'INV_GENEALOGY_ORIGIN'
         AND lookup_code = p_genealogy_origin;

      IF l_dummy = 0 THEN
        fnd_message.set_name('INV', 'INV_FIELD_INVALID');
        fnd_message.set_token('ENTITY1', 'p_genealogy_origin');
        fnd_msg_pub.ADD;
        RAISE lg_exc_error;
      END IF;
    END IF;

     -- Validate values are :
        --  1-  Assembly component
        --  2-  Lot split
        --  3-  lot merge
        --  5-  Asset
        -- if p_object_type = 2 then p_genealogy_type of 1 is valid
        -- otherwise all of the above are valid
    IF  p_genealogy_type NOT IN (1, 2, 3, 5)
        AND p_genealogy_type IS NOT NULL THEN
      fnd_message.set_name('INV', 'INV_FIELD_INVALID');
      fnd_message.set_token('ENTITY1', 'P_genealogy_type');
      fnd_msg_pub.ADD;
      RAISE lg_exc_error;
    END IF;

    IF p_object_type = 2 THEN
      IF p_genealogy_type NOT IN (1, 5) THEN
        fnd_message.set_name('INV', 'INV_FIELD_INVALID');
        fnd_message.set_token('ENTITY1', 'P_genealogy_type');
        fnd_msg_pub.ADD;
        RAISE lg_exc_error;
      END IF;
    END IF;

    -- If EAM object validate whether the object exists in the table
    -- If it does, check whether there exists a NULL end date for the last entry of the object
    IF p_genealogy_type = 5 THEN
      IF p_end_date_active IS NULL THEN
        fnd_message.set_name('INV', 'INV_EAM_NULL_END_DATE');
        fnd_msg_pub.ADD;
        RAISE lg_exc_error;
      END IF;

      BEGIN
        SELECT 'Y'
          INTO l_dummy_char
          FROM DUAL
         WHERE EXISTS( SELECT *
                         FROM mtl_object_genealogy
                        WHERE genealogy_type = 5
                          AND object_id = l_object_id
                          AND end_date_active IS NULL);

        SELECT start_date_active
          INTO l_dummy_date
          FROM mtl_object_genealogy
         WHERE genealogy_type = 5
           AND object_id = l_object_id
           AND end_date_active IS NULL;

        IF (p_end_date_active < l_dummy_date) THEN
          fnd_message.set_name('INV', 'INV_EAM_END_START_DATE_INVALID');
          fnd_message.set_token('ENTITY1', TO_CHAR(p_end_date_active, 'DD-MON-YYYY HH24:MI:SS'));
          fnd_message.set_token('ENTITY2', TO_CHAR(l_dummy_date, 'DD-MON-YYYY HH24:MI:SS'));
          fnd_msg_pub.ADD;
          RAISE lg_exc_error;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_EAM_GEN_NOEXIST');
          fnd_msg_pub.ADD;
          RAISE lg_exc_error;
      END;
    END IF;

    UPDATE mtl_object_genealogy
       SET last_update_date = SYSDATE
         , last_updated_by = -1
         , end_date_active = p_end_date_active
         , update_txn_id = p_update_txn_id
         , last_update_login = -1
         , request_id = fnd_global.conc_request_id
         , program_application_id = fnd_global.prog_appl_id
         , program_id = fnd_global.conc_program_id
         , program_update_date = SYSDATE
     WHERE object_id = l_object_id
       AND end_date_active IS NULL;

    -- End of API body.
    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN lg_exc_error THEN
      ROLLBACK TO update_genealogy_pub;
      x_return_status  := lg_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN lg_exc_unexpected_error THEN
      ROLLBACK TO update_genealogy_pub;
      x_return_status  := lg_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_genealogy_pub;
      x_return_status  := lg_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
  END update_genealogy;

  PROCEDURE insert_flow_genealogy(
    p_api_version               IN            NUMBER
  , p_init_msg_list             IN            VARCHAR2 := gen_fnd_g_false
  , p_commit                    IN            VARCHAR2 := gen_fnd_g_false
  , p_validation_level          IN            NUMBER := gen_fnd_valid_level_full
  , p_transaction_source_id     IN            NUMBER
  , p_completion_transaction_id IN            NUMBER
  , p_parent_object_id          IN            NUMBER := NULL
  , p_parent_object_number      IN            VARCHAR2 := NULL
  , p_parent_inventory_item_id  IN            NUMBER := NULL
  , p_parent_org_id             IN            NUMBER := NULL
  , p_genealogy_origin          IN            NUMBER := NULL
  , p_genealogy_type            IN            NUMBER := NULL
  , p_start_date_active         IN            DATE := SYSDATE
  , p_end_date_active           IN            DATE := NULL
  , p_origin_txn_id             IN            NUMBER := NULL
  , p_update_txn_id             IN            NUMBER := NULL
  , x_return_status             OUT NOCOPY    VARCHAR2
  , x_msg_count                 OUT NOCOPY    NUMBER
  , x_msg_data                  OUT NOCOPY    VARCHAR2
  --,   debug_count                     OUT NUMBER
  ) IS
    l_transaction_action_id      NUMBER         := 1;
    l_transaction_source_type_id NUMBER         := 5;
    l_api_version       CONSTANT NUMBER         := 1.0;
    l_api_name          CONSTANT VARCHAR2(30)   := 'insert_flow_genealogy';

    CURSOR childlotmmtt(p_transaction_source_id NUMBER, p_completion_transaction_id NUMBER) IS
      SELECT mtlt.lot_number
           , mmtt.organization_id
           , mmtt.inventory_item_id
        FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
       WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id
         AND mmtt.transaction_source_id = p_transaction_source_id
         AND mmtt.completion_transaction_id = p_completion_transaction_id
         AND mmtt.transaction_action_id = l_transaction_action_id
         AND mmtt.transaction_source_type_id = l_transaction_source_type_id;

    CURSOR childlotmmt(p_transaction_source_id NUMBER, p_completion_transaction_id NUMBER) IS
      SELECT mtlt.lot_number
           , mmtt.organization_id
           , mmtt.inventory_item_id
           , mmtt.transaction_id
        FROM mtl_material_transactions mmtt, mtl_transaction_lot_numbers mtlt
       WHERE mmtt.transaction_id = mtlt.transaction_id
         AND mmtt.transaction_source_id = p_transaction_source_id
         AND mmtt.completion_transaction_id = p_completion_transaction_id
         AND mmtt.transaction_action_id = l_transaction_action_id
         AND mmtt.transaction_source_type_id = l_transaction_source_type_id;

    l_object_number              VARCHAR2(80); /* 5209767: Made the l_object_number size 80 from 31*/
    l_inventory_item_id          NUMBER;
    l_organization_id            NUMBER;
    l_object_type                NUMBER         := 1;
    l_parent_object_type         NUMBER         := 1;
    l_return_status              VARCHAR2(10);
    l_count                      NUMBER;
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);
    l_origin_txn_id              NUMBER;
    l_debug                      NUMBER  :=1 ; --       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    -- {{-  RT: Flow Genealogy. No direct change has been made to this }}
    IF (l_debug = 1) THEN
      mydebug('Inside Insert_Flow_Genealogy');
      mydebug('p_completion_transaction_id is '|| p_completion_transaction_id);
      mydebug('p_transaction_source_id is '|| p_transaction_source_id);
      mydebug('p_parent_object_number = '|| p_parent_object_number
           || ' p_parent_inventory_item_id = ' || p_parent_inventory_item_id );
      mydebug( 'p_parent_org_id = '|| p_parent_org_id || ' p_genealogy_origin = '
               || p_genealogy_origin || ' p_genealogy_type = ' || p_genealogy_type );
      mydebug( 'p_origin_txn_id = ' || p_origin_txn_id
            || ' p_update_txn_id = ' || p_update_txn_id
            || ' p_start_date_active = ' || TO_CHAR(p_start_date_active, 'DD-MON-RRRR')
            || ' p_end_date_active = ' || TO_CHAR(p_end_date_active, 'DD-MON-RRRR') );
    END IF;

    -- Standard Start of API savepoint
    SAVEPOINT apiinsert_genealogy_apipub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE lg_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    x_msg_count      := 0;
    x_return_status  := lg_ret_sts_success;

    IF p_transaction_source_id IS NULL THEN
      fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE lg_exc_error;
    END IF;

    IF p_completion_transaction_id IS NULL THEN
      fnd_message.set_name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
      fnd_msg_pub.ADD;
      RAISE lg_exc_error;
    END IF;

    OPEN childlotmmtt(p_transaction_source_id, p_completion_transaction_id);

    LOOP
      IF (l_debug = 1) THEN
        mydebug('inside Loop to retrieve child lot');
      END IF;

      FETCH childlotmmtt INTO l_object_number, l_organization_id, l_inventory_item_id;
      EXIT WHEN childlotmmtt%NOTFOUND;

      -- call insert_genealogy for each component lot.
      IF (l_debug = 1) THEN
        mydebug(l_object_number || ' ' || l_organization_id || ' ' || l_inventory_item_id);
        mydebug('call insert_genealogy');
      END IF;

      inv_genealogy_pub.insert_genealogy(
        p_api_version                => 1.0
      , p_init_msg_list              => lg_fnd_g_false
      , p_commit                     => lg_fnd_g_false
      , p_validation_level           => lg_fnd_valid_level_full
      , p_object_type                => l_object_type
      , p_parent_object_type         => l_parent_object_type
      , p_object_id                  => NULL
      , p_object_number              => l_object_number
      , p_inventory_item_id          => l_inventory_item_id
      , p_org_id                     => l_organization_id
      , p_parent_object_id           => NULL
      , p_parent_object_number       => p_parent_object_number
      , p_parent_inventory_item_id   => p_parent_inventory_item_id
      , p_parent_org_id              => p_parent_org_id
      , p_genealogy_origin           => p_genealogy_origin
      , p_genealogy_type             => p_genealogy_type
      , p_start_date_active          => SYSDATE
      , p_end_date_active            => NULL
      , p_origin_txn_id              => p_origin_txn_id
      , p_update_txn_id              => NULL
      , x_return_status              => l_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data);

      IF l_return_status <> lg_ret_sts_success THEN
        RAISE lg_exc_error;
      END IF;
    END LOOP;

    CLOSE childlotmmtt;

    SELECT COUNT(*)
      INTO l_count
      FROM mtl_material_transactions_temp mmtt, mtl_transaction_lots_temp mtlt
     WHERE mmtt.transaction_temp_id = mtlt.transaction_temp_id
       AND mmtt.transaction_source_id = p_transaction_source_id
       AND mmtt.transaction_action_id = l_transaction_action_id
       AND mmtt.transaction_source_type_id = l_transaction_source_type_id
       AND mmtt.completion_transaction_id = p_completion_transaction_id;

    IF (l_count = 0) THEN
      OPEN childlotmmt(p_transaction_source_id, p_completion_transaction_id);

      LOOP
        IF (l_debug = 1) THEN
          mydebug('Inside retreive child lot from mmt');
        END IF;

        FETCH childlotmmt INTO l_object_number, l_organization_id, l_inventory_item_id, l_origin_txn_id;
        EXIT WHEN childlotmmt%NOTFOUND;

        -- call insert_genealogy for each component lot.
        IF (l_debug = 1) THEN
          mydebug(l_object_number || ' ' || l_organization_id || ' ' || l_inventory_item_id);
          mydebug('call insert_genealogy');
        END IF;

        inv_genealogy_pub.insert_genealogy(
          p_api_version                => 1.0
        , p_init_msg_list              => lg_fnd_g_false
        , p_commit                     => lg_fnd_g_false
        , p_validation_level           => lg_fnd_valid_level_full
        , p_object_type                => l_object_type
        , p_parent_object_type         => l_parent_object_type
        , p_object_id                  => NULL
        , p_object_number              => l_object_number
        , p_inventory_item_id          => l_inventory_item_id
        , p_org_id                     => l_organization_id
        , p_parent_object_id           => NULL
        , p_parent_object_number       => p_parent_object_number
        , p_parent_inventory_item_id   => p_parent_inventory_item_id
        , p_parent_org_id              => p_parent_org_id
        , p_genealogy_origin           => p_genealogy_origin
        , p_genealogy_type             => p_genealogy_type
        , p_start_date_active          => SYSDATE
        , p_end_date_active            => NULL
        , p_origin_txn_id              => l_origin_txn_id
        , p_update_txn_id              => NULL
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                   => l_msg_data);

        IF l_return_status <> lg_ret_sts_success THEN
          RAISE lg_exc_error;
        END IF;
      END LOOP;

      CLOSE childlotmmt;
    END IF;

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN lg_exc_error THEN
      IF (l_debug = 1) THEN
        mydebug('exception G_EXC_ERROR'|| x_msg_data);
      END IF;

      ROLLBACK TO save_insert_genealogy;
      x_return_status  := lg_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN lg_exc_unexpected_error THEN
      IF (l_debug = 1) THEN
        mydebug('exception G_UNEXC_ERROR'|| x_msg_data);
      END IF;

      ROLLBACK TO save_insert_genealogy;
      x_return_status  := lg_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        mydebug('exception WHEN OTHERS'|| x_msg_data);
      END IF;

      ROLLBACK TO save_insert_genealogy;
      x_return_status  := lg_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
  END insert_flow_genealogy;



PROCEDURE DELETE_EAM_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := gen_fnd_g_false,
  P_COMMIT                       IN VARCHAR2 := gen_fnd_g_false,
  P_VALIDATION_LEVEL             IN NUMBER   := gen_fnd_valid_level_full,
  P_OBJECT_ID                    IN NUMBER,
  P_START_DATE_ACTIVE		 IN DATE,
  P_END_DATE_ACTIVE		 IN DATE,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'delete_row';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  BEGIN
      SAVEPOINT inv_eam_genealogy;

   -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE lg_exc_unexpected_error;
      END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

   -- Initialize API return status to success
      x_return_status := lg_ret_sts_success;

   -- API body

 	Delete from mtl_object_genealogy
        where object_id = p_object_id
	and start_date_active = p_start_date_active
	and end_date_active = p_end_date_active
	and genealogy_type = 5;

   -- End of API body.
   -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN lg_exc_error THEN
         ROLLBACK TO inv_eam_genealogy;
         x_return_status := lg_ret_sts_error;
         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
      WHEN lg_exc_unexpected_error THEN
         ROLLBACK TO inv_eam_genealogy;
         x_return_status := lg_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
            p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO inv_eam_genealogy;
         x_return_status := lg_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

END Delete_EAM_Row;

PROCEDURE parameter_validations(
    p_validation_level         IN            NUMBER   := gen_fnd_valid_level_full
  , p_object_type              IN            NUMBER
  , p_parent_object_type       IN            NUMBER
  , p_object_id                IN OUT NOCOPY NUMBER
  , p_object_number            IN            VARCHAR2
  , p_inventory_item_id        IN            NUMBER
  , p_org_id                   IN            NUMBER
  , p_parent_object_id         IN OUT NOCOPY NUMBER
  , p_parent_object_number     IN            VARCHAR2
  , p_parent_inventory_item_id IN            NUMBER
  , p_parent_org_id            IN            NUMBER
  , p_genealogy_origin         IN            NUMBER
  , p_genealogy_type           IN            NUMBER
  , p_start_date_active        IN            DATE
  , p_end_date_active          IN            DATE
  , p_origin_txn_id            IN            NUMBER
  , p_update_txn_id            IN            NUMBER
  , p_object_type2             IN OUT NOCOPY NUMBER
  , p_object_id2               IN OUT NOCOPY NUMBER
  , p_object_number2           IN            VARCHAR2
  , p_parent_object_type2      IN OUT NOCOPY NUMBER
  , p_parent_object_id2        IN OUT NOCOPY NUMBER
  , p_parent_object_number2    IN            VARCHAR2
  , p_child_lot_control_code   IN            NUMBER
  , p_parent_lot_control_code  IN            NUMBER
  , p_action                   IN            VARCHAR2
  , p_debug                    IN            NUMBER
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2)
IS
    l_api_name        CONSTANT VARCHAR2(30)    := 'parameter_validations';
    l_dummy                    NUMBER;
    l_org_id                   NUMBER;
    retval                     NUMBER;
    l_parent_org_id            NUMBER;
    l_object_id                NUMBER;
    l_parent_object_id         NUMBER;
    l_object_id2               NUMBER;
    l_parent_object_id2        NUMBER;
    l_object_type2             NUMBER;
    l_parent_object_type2      NUMBER;
    l_parent_object_type       NUMBER;
    l_parent_inventory_item_id NUMBER;
    l_inventory_item_id        NUMBER;
    l_child_item_type          NUMBER;
    l_parent_item_type         NUMBER;
    l_object_table             object_id_tbl_t;
    l_serial_number            VARCHAR2(30);
    l_invalid_field_msg        VARCHAR2(50);
    l_invalid_comb_msg         VARCHAR2(150);
    l_child_lot_control_code   NUMBER;
    l_parent_lot_control_code  NUMBER;
    l_action                   VARCHAR2(10);
  BEGIN
    x_return_status  := lg_ret_sts_success;
    -- Standard Start of API savepoint
    SAVEPOINT save_parameter_validations;

    g_mod_name := 'parameter_validations';

    IF (p_debug = 1) THEN
       mydebug('Entered  parameter_validations ...');
       mydebug('p_validation_level: '  || p_validation_level  );
       mydebug('p_object_type: '  || p_object_type  );
       mydebug('p_parent_object_type: '  || p_parent_object_type  );
       mydebug('p_object_id: '  || p_object_id  );
       mydebug('p_object_number: '  || p_object_number  );
       mydebug('p_inventory_item_id: '   || p_inventory_item_id   );
       mydebug('p_org_id: '  || p_org_id  );
       mydebug('p_parent_object_id: '  || p_parent_object_id  );
       mydebug('p_parent_object_number: '  || p_parent_object_number  );
       mydebug('p_parent_inventory_item_id: '  || p_parent_inventory_item_id  );
       mydebug('p_parent_org_id: '  || p_parent_org_id  );
       mydebug('p_genealogy_origin: '  || p_genealogy_origin  );
       mydebug('p_genealogy_type: '  || p_genealogy_type  );
       mydebug('p_start_date_active: '  || p_start_date_active  );
       mydebug('p_end_date_active: '  || p_end_date_active  );
       mydebug('p_origin_txn_id: '  || p_origin_txn_id  );
       mydebug('p_update_txn_id: '   || p_update_txn_id   );
       mydebug('p_object_type2: '  || p_object_type2  );
       mydebug('p_object_id2: '  || p_object_id2  );
       mydebug('p_object_number2: '  || p_object_number2  );
       mydebug('p_parent_object_type2: '  || p_parent_object_type2  );
       mydebug('p_parent_object_id2: '   || p_parent_object_id2   );
       mydebug('p_parent_object_number2: '  || p_parent_object_number2  );
       mydebug('p_child_lot_control_code: '  || p_child_lot_control_code  );
       mydebug('p_parent_lot_control_code: '  || p_parent_lot_control_code  );
       mydebug('p_action: '  || p_action  );
       mydebug('p_debug: '  || p_debug  );
    END IF;

    l_object_type2 := p_object_type2;
    l_parent_object_type2 := p_parent_object_type2;
    l_child_lot_control_code    := p_child_lot_control_code ;
    l_parent_lot_control_code   := p_parent_lot_control_code ;

    IF (p_debug = 1) THEN
        mydebug('l_object_type2 : ' || l_object_type2);
        mydebug('l_parent_object_type2 : ' || l_parent_object_type2);
        mydebug('l_child_lot_control_code : ' || l_child_lot_control_code);
        mydebug('l_parent_lot_control_code : ' || l_parent_lot_control_code);
    END IF;

    -- R12 Genealogy Project: Added the check for p_validation_level and only if
    -- it is full that we should do certain validations otherwise not

    IF p_validation_level = lg_fnd_valid_level_full THEN
       IF (p_debug = 1) THEN
          mydebug('{{- Only if p_validation_level is FULL that the input parameters will be validated }}');
       END IF;

       IF p_object_type IS NULL THEN
         IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: P_object_type'); END IF;

         x_return_status  := lg_ret_sts_error; -- R12
         fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
         fnd_message.set_token('ATTRIBUTE', 'p_object_type');
         fnd_msg_pub.ADD;
       END IF;

       IF p_object_id IS NULL THEN
         IF (p_debug = 1) THEN mydebug('p_object_id is null'); END IF;

         IF p_object_number IS NULL  OR p_inventory_item_id IS NULL OR p_org_id IS NULL THEN
           IF p_object_number IS NULL THEN
             IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_object_number'); END IF;

             fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE', 'p_object_number');
             fnd_msg_pub.ADD;
           END IF;

           --R12 IF p_inventory_item_id IS NULL THEN
           IF  p_object_type <> 5 AND p_inventory_item_id IS NULL THEN
              /* {{ - If object_id is not passed then inventory_item_id is necessary along with
                    object_number and org_id only if this object is not of type JOB = 5 }} */
             IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_inventory_item_id'); END IF;

             fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE', 'p_inventory_item_id');
             fnd_msg_pub.ADD;
           END IF;

           IF p_org_id IS NULL THEN
             IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_org_id'); END IF;

             fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE', 'p_org_id');
             fnd_msg_pub.ADD;
           END IF;

           x_return_status  := lg_ret_sts_error; -- R12
         END IF;
       END IF;

       IF (p_debug = 1) THEN mydebug('After validating Child details 1 ' || x_return_status); END IF;

       IF p_parent_object_id IS NULL THEN
         IF (p_debug = 1) THEN mydebug('p_parent_object_id is null'); END IF;

         IF p_parent_object_number IS NULL
            OR p_parent_inventory_item_id IS NULL
            OR p_parent_org_id IS NULL THEN

           IF p_parent_object_number IS NULL THEN
             IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_parent_object_number'); END IF;

             fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE', 'p_parent_object_number');
             fnd_msg_pub.ADD;
           END IF;

           IF  p_parent_object_type <> 5 AND p_parent_inventory_item_id IS NULL THEN
             IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_parent_inventory_item_id'); END IF;

             fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE', 'p_parent_inventory_item_id');
             fnd_msg_pub.ADD;
           END IF;

           IF p_parent_org_id IS NULL THEN
             IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_parent_org_id'); END IF;

             fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE', 'p_parent_org_id');
             fnd_msg_pub.ADD;
           END IF;

           x_return_status  := lg_ret_sts_error; -- R12
         END IF;
       END IF;

       IF (p_debug = 1) THEN mydebug('After validating Parent Object details 1: ' || x_return_status); END IF;

       -- Object type can be between 1 and 5 .
       -- If invalid return an error.
       IF p_object_type < 1 OR p_object_type > 5 THEN
         x_return_status  := lg_ret_sts_error; -- R12
         IF (p_debug = 1) THEN mydebug('INV_FIELD_INVALID - p_object_type'); END IF;
         fnd_message.set_name('INV', 'INV_FIELD_INVALID');
         fnd_message.set_token('ENTITY1', 'p_object_type');
         fnd_msg_pub.ADD;
       END IF;

       IF (p_parent_object_type < 1 OR p_parent_object_type > 5) THEN
         x_return_status  := lg_ret_sts_error; -- R12
         IF (p_debug = 1) THEN mydebug('INV_FIELD_INVALID - p_parent_object_type'); END IF;
           fnd_message.set_name('INV', 'INV_FIELD_INVALID');
           fnd_message.set_token('ENTITY1', 'p_parent_object_type');
           fnd_msg_pub.ADD;
       END IF;

       -- R12 Genealogy Enhancements : Validate second set of object and parent object details

       IF (p_debug = 1) THEN
          mydebug('{{- Validate the second set of object_details in columns with suffix 2 }}'
                               || '{{  It applies to Lot+Serial Controlled items }}');
          mydebug('x_return_status: ' || x_return_status);
       END IF;

       IF (p_object_type = 2 AND (p_object_id2 IS NOT NULL OR p_object_number2 IS NOT NULL) )
            AND l_child_lot_control_code IS NULL  AND p_genealogy_type <> 5 THEN
            -- EAM genealogy is never for Lot+serial controlled items, therefore
            -- it is not necessary to derive lot_control_code of the item and therefore
            -- inventory_item_id is not necessary
          IF (p_debug = 1) THEN
             mydebug('{{- If p_object_type is 2 (serial) then check the lot control code }}' ||
                     '{{  of the child item, only if it is 2 that the second set of child object }}'||
                     '{{  details are necessary }} ');
          END IF;

          l_inventory_item_id := p_inventory_item_id ;
          IF l_inventory_item_id is NULL THEN
             BEGIN
                SELECT INVENTORY_ITEM_ID
                INTO   l_inventory_item_id
                FROM   mtl_serial_numbers
                WHERE  gen_object_id = p_object_id
                AND    current_Organization_id   = p_org_id;
             EXCEPTION WHEN NO_DATA_FOUND THEN

             IF (p_debug = 1) THEN mydebug('no data found ...child  mtl_serial_numbers '); END IF;
             x_return_status  := lg_ret_sts_error; -- R12
             fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE', 'l_inventory_item_id');
             fnd_msg_pub.ADD;
             END ;

             IF (p_debug = 1) THEN mydebug('l_inventory_item_id :' || l_inventory_item_id); END IF;
          END IF;
          IF l_inventory_item_id is NOT NULL THEN
             IF (p_debug = 1) THEN mydebug('l_inventory_item_id is not null ' ); END IF;

             SELECT lot_control_code
             INTO   l_child_lot_control_code
             FROM   mtl_system_items_b
             WHERE  inventory_item_id = l_inventory_item_id
             AND    Organization_id   = p_org_id;

          END IF;
       END IF;

       IF (p_debug = 1) THEN mydebug('l_child_lot_control_code: x_return_status: ' || l_child_lot_control_code
                                     || ':' || x_return_status); END IF;

       IF (p_parent_object_type = 2 AND (p_parent_object_id2 IS NOT NULL OR p_parent_object_number2 IS NOT NULL))
           and l_parent_lot_control_code is NULL  AND p_genealogy_type <> 5 THEN
          IF (p_debug = 1) THEN
             mydebug('{{- If p_parent_object_type is 2 (serial) then check the lot control code }}' ||
                     '{{  for parent item, only if it is 2 that the second set of parent object details}}' ||
                     '{{  are necessary }} ');
          END IF;

          l_parent_inventory_item_id := p_parent_inventory_item_id ;
          IF  l_parent_inventory_item_id is NULL OR   l_parent_inventory_item_id = 0 THEN
             BEGIN
                SELECT INVENTORY_ITEM_ID
                INTO   l_parent_inventory_item_id
                FROM   mtl_serial_numbers
                WHERE  gen_object_id = p_parent_object_id
                AND    current_Organization_id   = p_parent_org_id;
             EXCEPTION WHEN NO_DATA_FOUND THEN
               x_return_status  := lg_ret_sts_error; -- R12
               IF (p_debug = 1) THEN mydebug('no data found ...parent mtl_serial_numbers '); END IF;
               fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
               fnd_message.set_token('ATTRIBUTE', 'l_parent_inventory_item_id');
               fnd_msg_pub.ADD;
             END ;
             IF (p_debug = 1) THEN mydebug('l_parent_inventory_item_id '|| l_parent_inventory_item_id ); END IF;
          END IF;
          IF  l_parent_inventory_item_id is NOT NULL THEN
             SELECT lot_control_code
             INTO   l_parent_lot_control_code
             FROM   mtl_system_items_b
             WHERE  inventory_item_id = l_parent_inventory_item_id
             AND    Organization_id   = p_parent_org_id;

          END IF;
       END IF;
       IF (p_debug = 1) THEN mydebug('l_parent_lot_control_code: x_return_status: ' || l_parent_lot_control_code
                                     || ':' || x_return_status); END IF;

       IF l_child_lot_control_code = 2 THEN
          IF (p_debug = 1) THEN
             mydebug('{{Only if child is lot controlled that we need to validate second set of object details }}' );
          END IF;

          IF (l_object_type2 IS NOT NULL AND l_object_type2 <> 1)  THEN
             IF (p_debug = 1) THEN mydebug('{{- p_object_type2 can only be = 1 (lot) }} '); END IF;
             x_return_status  := lg_ret_sts_error; -- R12
             fnd_message.set_name('INV', 'INV_FIELD_INVALID');
             fnd_message.set_token('ENTITY1', 'l_object_type2');
             fnd_msg_pub.ADD;
          ELSE
            IF (l_object_type2 IS NULL )
            THEN
               IF (p_debug = 1) THEN mydebug('If P_object_type2 is null assign 1 (lot)'); END IF;
               l_object_type2 := 1; --Lot
            END IF;
          END IF;


          /*Mrana : 11/02/05: Do not bother validating or derivig id2 ..
 *                :  for backward compatibility where lot+serial assemblies
 *                : might input only serial number and  not both lotand  serial
 *       IF p_object_id2 IS NULL THEN
            IF (p_debug = 1) THEN mydebug('p_object_id2 is NULL'); END IF;
            IF p_object_number2 IS NULL OR p_inventory_item_id IS NULL OR p_org_id IS NULL THEN
               IF (p_debug = 1) THEN mydebug('p_object_number2 or p_inventory_item_id is NULL' ||
                                                            ' or p_org_id is NULL'); END IF;
               IF p_object_number2 IS NULL THEN
                  IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_object_number2'); END IF;

                  fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
                  fnd_message.set_token('ATTRIBUTE', 'p_object_number2');
                  fnd_msg_pub.ADD;
               END IF;
               IF  p_object_type <> 5 AND p_inventory_item_id IS NULL THEN
                 IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_inventory_item_id'); END IF;

                 fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
                 fnd_message.set_token('ATTRIBUTE', 'p_inventory_item_id');
                 fnd_msg_pub.ADD;
               END IF;


               IF p_org_id IS NULL THEN
                 IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_org_id'); END IF;

                 fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
                 fnd_message.set_token('ATTRIBUTE', 'p_org_id');
                 fnd_msg_pub.ADD;
               END IF;

               x_return_status  := lg_ret_sts_error; -- R12
               --RAISE lg_exc_error;
            END IF;
          END IF; */
       END IF;

       IF (p_debug = 1) THEN
                  mydebug('After validating Child Object 2 details');
                  mydebug('x_return_status: ' || x_return_status);
       END IF;

       IF l_parent_lot_control_code = 2 THEN
          IF (l_parent_object_type2 IS NOT NULL AND l_parent_object_type2 <> 1) THEN
             IF (p_debug = 1) THEN mydebug('{{- p_parent_object_type2 can only be = 1 (lot) }} '); END IF;
             fnd_message.set_name('INV', 'INV_FIELD_INVALID');
             fnd_message.set_token('ENTITY1', 'l_parent_object_type2');
             fnd_msg_pub.ADD;
             RAISE lg_exc_error;
          ELSE
            IF (l_parent_object_type2 IS NULL )
            THEN
               IF (p_debug = 1) THEN mydebug('If P_object_type2 is null assign 1 (lot)'); END IF;
               l_parent_object_type2 := 1; --Lot
             END IF;
          END IF;

          /*Mrana : 11/02/05: Do not bother validating or derivig id2 ..
 *                :  for backward compatibility where lot+serial assemblies
 *                : might input only serial number and  not both lotand  serial
          IF p_parent_object_id2 IS NULL THEN
            IF (p_debug = 1) THEN mydebug('p_parent_object_id2 is NULL'); END IF;
            IF p_parent_object_number2 IS NULL
               OR p_parent_inventory_item_id IS NULL
               OR p_parent_org_id IS NULL THEN
               IF (p_debug = 1) THEN mydebug('p_parent_object_number2 or -p_parent_object_type2 ' ||
                       '<> 5 and p_inventory_item_id is NULL- or p_org_id is NUll'); END IF;
              IF p_parent_object_number2 IS NULL THEN
                IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_parent_object_number2'); END IF;

                fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
                fnd_message.set_token('ATTRIBUTE', 'p_parent_object_number2');
                fnd_msg_pub.ADD;
              END IF;

              IF  l_parent_object_type2 <> 5 AND p_parent_inventory_item_id IS NULL THEN
                IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_parent_inventory_item_id'); END IF;

                fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
                fnd_message.set_token('ATTRIBUTE', 'p_parent_inventory_item_id');
                fnd_msg_pub.ADD;
              END IF;

              IF p_parent_org_id IS NULL THEN
                 IF (p_debug = 1) THEN mydebug('INV_ATTRIBUTE_REQUIRED: p_parent_org_id'); END IF;

                 fnd_message.set_name('INV', 'INV_ATTRIBUTE_REQUIRED');
                 fnd_message.set_token('ATTRIBUTE', 'p_parent_org_id');
                 fnd_msg_pub.ADD;
               END IF;

              x_return_status  := lg_ret_sts_error; -- R12
              --RAISE lg_exc_error;
            END IF;
          END IF; */
       END IF;

       IF (p_debug = 1) THEN mydebug('After validating Parent Object 2 details');
                             mydebug('x_return_status: ' || x_return_status);
       END IF;
    END IF; -- Validation level is full

    IF x_return_status = lg_ret_sts_error
    THEN
       IF (p_debug = 1) THEN mydebug('{{ If any of the parameter validations failed, then raise  ' ||
                                      'an exception now..before validating the object ids }}');
       END IF;
       RAISE lg_exc_error;
    END IF;

    IF x_return_status = lg_ret_sts_unexp_error
    THEN
       IF (p_debug = 1) THEN mydebug('{{ If any of the parameter validations failed, then raise  ' ||
                                      'an exception now..before validating the object ids }}');
       END IF;
       RAISE lg_exc_unexpected_error;
    END IF;

    -- Validate the existence of object number in MTL_SERIAL_NUMBERS
    -- or MTL_LOT_NUMBERS depending on the object type.
    -- If object number is not found return an error.

    IF (p_debug = 1) THEN mydebug('Before deriving Object ID');
                          mydebug('LTRIM(RTRIM(p_object_number)) : ' ||
                               LTRIM(RTRIM(p_object_number)));
                          mydebug('LTRIM(RTRIM(p_parent_object_number)) : ' ||
                               LTRIM(RTRIM(p_parent_object_number))); END IF;


    l_invalid_field_msg := 'Object ID';
    l_invalid_comb_msg  := 'Org, Item and Object Number Combination';

    l_dummy := 0;
    IF p_object_type = 1 THEN
      IF p_object_id IS NOT NULL THEN
         IF p_validation_level = lg_fnd_valid_level_full THEN
           IF (p_debug = 1) THEN
              mydebug('{{- Only if p_validation_level is FULL that parameters- object id will be validated }}');
           END IF;
           SELECT COUNT(*)
             INTO l_dummy
             FROM mtl_lot_numbers
            WHERE gen_object_id = p_object_id;

           IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('lot not found using  - p_object_id'); END IF;
             fnd_message.set_name('INV', 'INV_FIELD_INVALID');
             fnd_message.set_token('ENTITY1', l_invalid_field_msg);
             fnd_msg_pub.ADD;
             --RAISE lg_exc_error;
           END IF;
         END IF;

        l_object_id  := p_object_id;
        IF (p_debug = 1) THEN mydebug('1: l_object_id : ' || l_object_id);
                              mydebug('1: p_object_id : ' || p_object_id); END IF;

      ELSE
        BEGIN
          SELECT gen_object_id
            INTO l_object_id
            FROM mtl_lot_numbers
           WHERE lot_number = LTRIM(RTRIM(p_object_number))
             AND inventory_item_id = p_inventory_item_id
             AND organization_id = p_org_id;
       IF (p_debug = 1) THEN mydebug('1: l_object_id: ' || l_object_id); END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('lot not found using  - p_object_number,'); END IF;
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
            fnd_message.set_token('ENTITY1', l_invalid_comb_msg);
            fnd_msg_pub.ADD;
            --RAISE lg_exc_error;
        END;
      END IF;
    ELSIF p_object_type = 2 THEN
      IF p_object_id IS NOT NULL THEN
         IF p_validation_level = lg_fnd_valid_level_full THEN
            SELECT COUNT(*)
              INTO l_dummy
              FROM mtl_serial_numbers
             WHERE gen_object_id = p_object_id;

            IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('Serial not found using  - p_object_id,'); END IF;
              fnd_message.set_name('INV', 'INV_FIELD_INVALID');
              fnd_message.set_token('ENTITY1', l_invalid_field_msg);
              fnd_msg_pub.ADD;
             -- RAISE lg_exc_error;
           END IF;
        END IF;

        l_object_id  := p_object_id;
        IF (p_debug = 1) THEN mydebug('2: l_object_id : ' || l_object_id);
                              mydebug('2: p_object_id : ' || p_object_id); END IF;

      ELSE
        BEGIN
          SELECT gen_object_id
            INTO l_object_id
            FROM mtl_serial_numbers
           WHERE serial_number = LTRIM(RTRIM(p_object_number))
             AND inventory_item_id = p_inventory_item_id
             AND current_organization_id = p_org_id;
       IF (p_debug = 1) THEN mydebug('2: l_object_id: ' || l_object_id); END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('Serial not found using  - p_object_number,'); END IF;
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
            fnd_message.set_token('ENTITY1', l_invalid_comb_msg);
            fnd_msg_pub.ADD;
            --RAISE lg_exc_error;
        END;
      END IF;
    ELSIF p_object_type = 5 THEN
      IF p_object_id IS NOT NULL THEN
        SELECT wip_entity_id
          INTO l_dummy
          FROM wip_entities
         WHERE gen_object_id = p_object_id;

        IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
          IF (p_debug = 1) THEN mydebug('Job not found using  - p_object_id,'); END IF;
          fnd_message.set_name('INV', 'INV_FIELD_INVALID');
          fnd_message.set_token('ENTITY1', l_invalid_field_msg);
          fnd_msg_pub.ADD;
          --RAISE lg_exc_error;
        END IF;

        l_object_id  := p_object_id;
        IF (p_debug = 1) THEN mydebug('5: l_object_id : ' || l_object_id);
                              mydebug('5: p_object_id : ' || p_object_id); END IF;

      ELSE
        BEGIN
          SELECT gen_object_id
            INTO l_object_id
            FROM wip_entities
           WHERE wip_entity_name = LTRIM(RTRIM(p_object_number))
             AND organization_id = p_org_id;
       IF (p_debug = 1) THEN mydebug('5: l_object_id: ' || l_object_id); END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             x_return_status  := lg_ret_sts_error; -- R12
            IF (p_debug = 1) THEN mydebug('Job not found using  - p_object_number,'); END IF;
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
            fnd_message.set_token('ENTITY1', l_invalid_comb_msg);
            fnd_msg_pub.ADD;
            --RAISE lg_exc_error;
        END;
      END IF;
    END IF;

    IF (p_debug = 1) THEN mydebug(' After deriving Object Id');
                          mydebug('x_return_status: ' || x_return_status); END IF;

    -- Validate the existence of parent object number in MTL_SERIAL_NUMBERS
    -- or MTL_LOT_NUMBERS depending on the object type.
    -- If parent object number is not found return an error.
    l_invalid_field_msg := 'Parent Object ID';
    l_invalid_comb_msg  := 'Parent Org, Item and Object Number Combination';
    IF p_parent_object_type = 1 THEN
      IF p_parent_object_id IS NOT NULL THEN
        IF p_validation_level = lg_fnd_valid_level_full THEN
           IF (p_debug = 1) THEN
              mydebug('{{- Only if p_validation_level is FULL that parameters- parent object_id will be validated }}');
           END IF;
           SELECT COUNT(*)
             INTO l_dummy
             FROM mtl_lot_numbers
            WHERE gen_object_id = p_parent_object_id;

           IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('Lot not found using  - p_parent_object_id,'); END IF;
             fnd_message.set_name('INV', 'INV_FIELD_INVALID');
             fnd_message.set_token('ENTITY1', l_invalid_field_msg);
             fnd_msg_pub.ADD;
             --RAISE lg_exc_error;
           END IF;
        END IF;

        l_parent_object_id  := p_parent_object_id;
        IF (p_debug = 1) THEN mydebug('1: l_parent_object_id : ' || l_parent_object_id);
                              mydebug('1: p_parent_object_id : ' || p_parent_object_id); END IF;

      ELSE
        BEGIN
          SELECT gen_object_id
            INTO l_parent_object_id
            FROM mtl_lot_numbers
           WHERE lot_number = LTRIM(RTRIM(p_parent_object_number))
             AND inventory_item_id = p_parent_inventory_item_id
             AND organization_id = p_parent_org_id;
      IF (p_debug = 1) THEN mydebug('1: l_parent_object_id: ' || l_parent_object_id); END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('Lot not found using  - p_parent_object_number,'); END IF;
            fnd_message.set_token('ENTITY1', l_invalid_comb_msg);
            fnd_msg_pub.ADD;
            --RAISE lg_exc_error;
        END;
      END IF;
    ELSIF p_parent_object_type = 2 THEN
      IF p_parent_object_id IS NOT NULL THEN
        IF p_validation_level = lg_fnd_valid_level_full THEN
           IF (p_debug = 1) THEN
              mydebug('{{- Only if p_validation_level is FULL that parameters- parent object details will be validated }}');
           END IF;
           SELECT COUNT(*)
             INTO l_dummy
             FROM mtl_serial_numbers
            WHERE gen_object_id = p_parent_object_id;

           IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('Serial not found using  - p_parent_object_id,'); END IF;
             fnd_message.set_name('INV', 'INV_FIELD_INVALID');
             fnd_message.set_token('ENTITY1', l_invalid_field_msg);
             fnd_msg_pub.ADD;
             --RAISE lg_exc_error;
           END IF;
        END IF;

        l_parent_object_id  := p_parent_object_id;
        IF (p_debug = 1) THEN mydebug('2: l_parent_object_id : ' || l_parent_object_id);
                              mydebug('2: p_parent_object_id : ' || p_parent_object_id); END IF;

      ELSE
        BEGIN
          SELECT gen_object_id
            INTO l_parent_object_id
            FROM mtl_serial_numbers
           WHERE serial_number = LTRIM(RTRIM(p_parent_object_number))
             AND inventory_item_id = p_parent_inventory_item_id
             AND current_organization_id = p_parent_org_id;
       IF (p_debug = 1) THEN mydebug('2: l_parent_object_id: ' || l_parent_object_id); END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('Serial not found using  - p_parent_object_number,'); END IF;
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
            fnd_message.set_token('ENTITY1', l_invalid_comb_msg);
            fnd_msg_pub.ADD;
            --RAISE lg_exc_error;
        END;
      END IF;
    ELSIF p_parent_object_type = 5 THEN
       -- Not putting p_validation around this since it belongs to EAM and will leave them to decide
      IF p_parent_object_id IS NOT NULL THEN
        SELECT wip_entity_id
          INTO l_dummy
          FROM wip_entities
         WHERE gen_object_id = p_parent_object_id;

        IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
          IF (p_debug = 1) THEN mydebug('Job not found using  - p_parent_object_id,'); END IF;
          fnd_message.set_name('INV', 'INV_FIELD_INVALID');
          fnd_message.set_token('ENTITY1', l_invalid_field_msg);
          fnd_msg_pub.ADD;
        --  RAISE lg_exc_error;
        END IF;

        l_parent_object_id  := p_parent_object_id;
        IF (p_debug = 1) THEN mydebug('5: l_parent_object_id : ' || l_parent_object_id);
                              mydebug('5: p_parent_object_id : ' || p_parent_object_id); END IF;

      ELSE
        BEGIN
          SELECT gen_object_id
            INTO l_parent_object_id
            FROM wip_entities
           WHERE wip_entity_name = LTRIM(RTRIM(p_parent_object_number))
             AND organization_id = p_parent_org_id;
       IF (p_debug = 1) THEN mydebug('5: l_parent_object_id: ' || l_parent_object_id); END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             x_return_status  := lg_ret_sts_error; -- R12
            IF (p_debug = 1) THEN mydebug('Job not found using  - p_parent_object_number,'); END IF;
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
            fnd_message.set_token('ENTITY1', l_invalid_comb_msg);
            fnd_msg_pub.ADD;
            --RAISE lg_exc_error;
        END;
      END IF;
    END IF;

    IF (p_debug = 1) THEN mydebug(' After deriving Parent Object Id');
                          mydebug('x_return_status: ' || x_return_status);
    END IF;

    l_invalid_field_msg := 'Object ID2';
    l_invalid_comb_msg  := 'Org, Item and Object Number2 Combination';

   -- R12 Genealogy Enhancements: Start
   --  Validate/Derive the second set of object details
    IF l_object_type2 = 1 THEN
      IF p_object_id2 IS NOT NULL THEN
         IF p_validation_level = lg_fnd_valid_level_full THEN
           IF (p_debug = 1) THEN
           mydebug('{{- Only if p_validation_level is FULL that parameters- object id2 will be validated }}');
           END IF;
           SELECT COUNT(*)
             INTO l_dummy
             FROM mtl_lot_numbers
            WHERE gen_object_id = p_object_id2;

           IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
            IF (p_debug = 1) THEN mydebug('Lot not found using  - p_object_id2,'); END IF;
             fnd_message.set_name('INV', 'INV_FIELD_INVALID');
             fnd_message.set_token('ENTITY1', l_invalid_field_msg);
             fnd_msg_pub.ADD;
             --RAISE lg_exc_error;
           END IF;
         END IF;

        l_object_id2  := p_object_id2;
      ELSE
         IF LTRIM(RTRIM(p_object_number2)) IS NOT NULL  THEN
           BEGIN
             SELECT gen_object_id
               INTO l_object_id2
               FROM mtl_lot_numbers
              WHERE lot_number = LTRIM(RTRIM(p_object_number2))
                AND inventory_item_id = p_inventory_item_id
                AND organization_id = p_org_id;
           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                x_return_status  := lg_ret_sts_error; -- R12
               IF (p_debug = 1) THEN mydebug('Lot not found using  - p_object_number2,'); END IF;
               fnd_message.set_name('INV', 'INV_FIELD_INVALID');
               fnd_message.set_token('ENTITY1', l_invalid_comb_msg);
               fnd_msg_pub.ADD;
               --RAISE lg_exc_error;
           END;
         ELSE
            l_object_id2  := NULL;
         END IF;
      END IF;
    END IF;

    IF (p_debug = 1) THEN
      mydebug(' After validating / deriving l_Object Id2: ' || l_object_id2);
      mydebug('x_return_status: ' || x_return_status);
    END IF;

    l_invalid_field_msg := 'Parent Object ID2';
    l_invalid_comb_msg  := 'Parent Org, Item and Object Number2 Combination';
    IF l_parent_object_type2 = 1 THEN
      IF p_parent_object_id2 IS NOT NULL THEN
        IF p_validation_level = lg_fnd_valid_level_full THEN
           IF (p_debug = 1) THEN
           mydebug('{{- Only if p_validation_level is FULL that parameters- parent object_id2 will be validated }}');
           END IF;
           SELECT COUNT(*)
             INTO l_dummy
             FROM mtl_lot_numbers
            WHERE gen_object_id = p_parent_object_id2;

           IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
             IF (p_debug = 1) THEN mydebug('Lot not found using  - p_parent_object_id2,'); END IF;
             fnd_message.set_name('INV', 'INV_FIELD_INVALID');
             fnd_message.set_token('ENTITY1', l_invalid_field_msg);
             fnd_msg_pub.ADD;
             --RAISE lg_exc_error;
           END IF;
        END IF;

        l_parent_object_id2  := p_parent_object_id2;
      ELSE
         IF LTRIM(RTRIM(p_parent_object_number2)) IS NOT NULL  THEN
            BEGIN
              SELECT gen_object_id
                INTO l_parent_object_id2
                FROM mtl_lot_numbers
               WHERE lot_number = LTRIM(RTRIM(p_parent_object_number2))
                 AND inventory_item_id = p_parent_inventory_item_id
                 AND organization_id = p_parent_org_id;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 x_return_status  := lg_ret_sts_error; -- R12
                fnd_message.set_name('INV', 'INV_FIELD_INVALID');
                fnd_message.set_token('ENTITY1', l_invalid_comb_msg);
                fnd_msg_pub.ADD;
                 IF (p_debug = 1) THEN mydebug('Lot not found using  - p_parent_object_number2,'); END IF;
                --RAISE lg_exc_error;
            END;
         ELSE
            l_parent_object_id2  := NULL;
         END IF;
      END IF;
    END IF;

    IF (p_debug = 1) THEN mydebug(' After validating/deriving Parent Object Id2: ' || l_parent_object_id2);
                          mydebug('x_return_status: ' || x_return_status);
    END IF;
   -- R12 Genealogy Enhancements: End
   --  Validate/Derive the second set of object details


    IF p_genealogy_origin IS NOT NULL THEN
       IF p_validation_level = lg_fnd_valid_level_full THEN
       -- {{- only if p_validation_level is FULL that the input parameters p_genealogy_origin will be validated }}
         SELECT COUNT(*)
           INTO l_dummy
           FROM mfg_lookups
          WHERE lookup_type = 'INV_GENEALOGY_ORIGIN'
            AND lookup_code = p_genealogy_origin;

          IF l_dummy = 0 THEN
             x_return_status  := lg_ret_sts_error; -- R12
            fnd_message.set_name('INV', 'INV_FIELD_INVALID');
            fnd_message.set_token('ENTITY1', 'p_genealogy_origin:' || TO_CHAR(p_genealogy_origin));
            fnd_msg_pub.ADD;
             IF (p_debug = 1) THEN mydebug('Gene. Origin not found in mfg_lookups,'); END IF;
            --RAISE lg_exc_error;
          END IF;
       END IF;
    END IF;

        -- Valid values are :
        --  1-  Assembly component
        --  2-  Lot split
        --  3-  lot merge
        --  5-  Asset
        -- if p_object_type = 2 then p_genealogy_type of 1 is valid otherwise all of the above are valid
        --  (Removed this condition in R12 )

    IF p_validation_level = lg_fnd_valid_level_full THEN
    -- {{- only if p_validation_level is FULL that the input parameters p_genealogy_origin will be validated }}
       IF  p_genealogy_type NOT IN (1, 2, 3, 4, 5)
           AND p_genealogy_type IS NOT NULL THEN
         x_return_status  := lg_ret_sts_error; -- R12
         fnd_message.set_name('INV', 'INV_FIELD_INVALID');
         fnd_message.set_token('ENTITY1', 'P_genealogy_type');
         fnd_msg_pub.ADD;
         IF (p_debug = 1) THEN mydebug('Gene. Type is invalid ,'); END IF;
         --RAISE lg_exc_error;
       END IF;
    END IF;

    /* {{- Removed this condition for R12 since we will have more genealogy types for object_type = 2(serials) }}

      {{  IF p_object_type = 2 THEN }}
         {{  IF p_genealogy_type NOT IN (1, 5) THEN }}
           fnd_message.set_name('INV', {{'  INV_FIELD_INVALID'}});
           fnd_message.set_token('ENTITY1', 'P_genealogy_type');
           fnd_msg_pub.ADD;
           RAISE lg_exc_error;
         END IF;
       END IF; */


   -- R12 Genealogy Enhancements: Start
   --  set Return parameters  or raise an exception if any of the above
   -- validations failed
    IF (p_debug = 1) THEN
       mydebug('l_object_id: '          || l_object_id  );
       mydebug('l_parent_object_id: '   || l_parent_object_id  );
       mydebug('l_object_id2: '         || l_object_id2  );
       mydebug('l_parent_object_id2: '  || l_parent_object_id2  );
       mydebug('x_return_status: '  || x_return_status  );
    END IF;

    IF l_object_id IS NULL OR l_parent_object_id IS NULL THEN
       x_return_status := lg_ret_sts_error;
         fnd_message.set_name('INV', 'INV_NULLOBJECTID'); -- mrana addmsg
         IF l_object_id is NULL THEN
            fnd_message.set_token('ENTITY1', 'p_object_number');
         ELSIF l_parent_object_id IS NULL THEN
            fnd_message.set_token('ENTITY1', 'p_parent_object_number');
         END IF;
         fnd_msg_pub.ADD;
         IF (p_debug = 1) THEN mydebug('Gene. Type is invalid ,'); END IF;
    END IF;

    IF x_return_status = lg_ret_sts_error
    THEN
       IF (p_debug = 1) THEN mydebug('{{ If any of the parameter validations failed, then raise  ' ||
                                      'an exception now..before validating the object ids }}');
       END IF;
       RAISE lg_exc_error;
    END IF;
    IF x_return_status = lg_ret_sts_unexp_error
    THEN
       IF (p_debug = 1) THEN mydebug('{{ If any of the parameter validations failed, then raise  ' ||
                                      'an exception now..before validating the object ids }}');
       END IF;
       RAISE lg_exc_unexpected_error;
    END IF;

    p_object_id                := l_object_id ;
    p_parent_object_id         := l_parent_object_id;
    p_object_type2             := l_object_type2;
    p_object_id2               := l_object_id2;
    p_parent_object_type2      := l_parent_object_type2 ;
    p_parent_object_id2        := l_parent_object_id2 ;

    IF (p_debug = 1) THEN
       mydebug('After setting value for IO parameters..before returning to caller ');
       mydebug('l_object_id2: '  || l_object_id2  );
       mydebug('l_parent_object_id2: '  || l_parent_object_id2  );
       mydebug('l_object_type2: '  || l_object_type2  );
       mydebug('l_parent_object_type2: '  || l_parent_object_type2  );
       mydebug('l_object_id: '  || l_object_id  );
       mydebug('l_parent_object_id: '  || l_parent_object_id  );
    END IF;

   -- R12 Genealogy Enhancements: End
   --  Return parameters
  EXCEPTION
    WHEN lg_exc_error THEN
      IF (p_debug = 1) THEN mydebug('exception G_EXC_ERROR'|| x_msg_data); END IF;
      x_return_status  := lg_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN lg_exc_unexpected_error THEN
      IF (p_debug = 1) THEN mydebug('exception G_UNEXC_ERROR'|| x_msg_data); END IF;
      x_return_status  := lg_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF (p_debug = 1) THEN mydebug('exception WHEN OTHERS'|| x_msg_data); END IF;
      x_return_status  := lg_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);

END parameter_validations;

-- R12 genealogy Enhancements : Added a new procedure to update genealogy
--- Primarily used to disable an existing relationship in case of serial
-- component or assembly returns in this release

PROCEDURE update_genealogy(
    p_api_version              IN            NUMBER
  , p_init_msg_list            IN            VARCHAR2 := gen_fnd_g_false
  , p_commit                   IN            VARCHAR2 := gen_fnd_g_false
  , p_validation_level         IN            NUMBER   := gen_fnd_valid_level_full
  , p_object_type              IN            NUMBER
  , p_parent_object_type       IN            NUMBER   := NULL
  , p_object_id                IN            NUMBER   := NULL
  , p_object_number            IN            VARCHAR2 := NULL
  , p_inventory_item_id        IN            NUMBER   := NULL
  , p_organization_id          IN            NUMBER   := NULL
  , p_parent_object_id         IN            NUMBER   := NULL
  , p_parent_object_number     IN            VARCHAR2 := NULL
  , p_parent_inventory_item_id IN            NUMBER   := NULL
  , p_parent_org_id            IN            NUMBER   := NULL
  , p_genealogy_origin         IN            NUMBER   := NULL
  , p_genealogy_type           IN            NUMBER   := NULL
  , p_start_date_active        IN            DATE     := SYSDATE
  , p_end_date_active          IN            DATE     := NULL
  , p_origin_txn_id            IN            NUMBER   := NULL
  , p_update_txn_id            IN            NUMBER   := NULL
  , p_object_type2             IN            NUMBER   := NULL
  , p_object_id2               IN            NUMBER   := NULL
  , p_object_number2           IN            VARCHAR2 := NULL
  , p_parent_object_type2      IN            NUMBER   := NULL
  , p_parent_object_id2        IN            NUMBER   := NULL
  , p_parent_object_number2    IN            VARCHAR2 := NULL
  , p_child_lot_control_code   IN            NUMBER   := NULL
  , p_parent_lot_control_code  IN            NUMBER   := NULL
  , p_transaction_type         IN            VARCHAR2 := NULL  -- ASSEMBLY_RETURN, COMP_RETURN, NULL
  , x_return_status            OUT NOCOPY    VARCHAR2
  , x_msg_count                OUT NOCOPY    NUMBER
  , x_msg_data                 OUT NOCOPY    VARCHAR2
  ) IS
   -- 2/2/06: Bug: 4997221 : Added new parameter p_transaction_type
    l_api_version     CONSTANT NUMBER          := 1.0;
    l_api_name        CONSTANT VARCHAR2(30)    := 'update_genealogy';
    l_org_id                   NUMBER;
    l_parent_org_id            NUMBER;
    l_object_id                NUMBER;
    l_parent_object_id         NUMBER;
    l_object_id2               NUMBER;
    l_parent_object_id2        NUMBER;
    l_object_type2             NUMBER;
    l_parent_object_type2      NUMBER;
    l_parent_object_type       NUMBER;
    l_parent_inventory_item_id NUMBER;
    l_inventory_item_id        NUMBER;
    l_child_item_type          NUMBER;
    l_parent_item_type         NUMBER;
    l_serial_number            VARCHAR2(30);
    l_debug                    NUMBER   :=1 ; --       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_invalid_field_msg        VARCHAR2(50);
    l_invalid_comb_msg         VARCHAR2(150);
    l_child_lot_control_code   NUMBER;
    l_parent_lot_control_code  NUMBER;
    l_action                   VARCHAR2(10);
    l_end_date_active          DATE;
    l_return_status            VARCHAR2(10);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(240);
  BEGIN
    -- Standard Start of API savepoint
    x_return_status  := lg_ret_sts_success;
    SAVEPOINT save_update_genealogy;
    g_mod_name := 'update_Genealogy';

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE lg_exc_unexpected_error;
    END IF;

    IF (l_debug = 1) THEN
       mydebug('In procedure: '  || g_mod_name  );
       mydebug('p_api_version: '  || p_api_version  );
       mydebug('p_init_msg_list: '  || p_init_msg_list  );
       mydebug('p_commit: '  || p_commit  );
       mydebug('p_validation_level: '  || p_validation_level  );
       mydebug('p_object_type: '  || p_object_type  );
       mydebug('p_parent_object_type: '  || p_parent_object_type  );
       mydebug('p_object_id: '  || p_object_id  );
       mydebug('p_object_number: '  || p_object_number  );
       mydebug('p_inventory_item_id: '   || p_inventory_item_id   );
       mydebug('p_organization_id: '  || p_organization_id  );
       mydebug('p_parent_object_id: '  || p_parent_object_id  );
       mydebug('p_parent_object_number: '  || p_parent_object_number  );
       mydebug('p_parent_inventory_item_id: '  || p_parent_inventory_item_id  );
       mydebug('p_parent_org_id: '  || p_parent_org_id  );
       mydebug('p_genealogy_origin: '  || p_genealogy_origin  );
       mydebug('p_genealogy_type: '  || p_genealogy_type  );
       mydebug('p_start_date_active: '  || p_start_date_active  );
       mydebug('p_end_date_active: '  || p_end_date_active  );
       mydebug('p_origin_txn_id: '  || p_origin_txn_id  );
       mydebug('p_update_txn_id: '   || p_update_txn_id   );
       mydebug('p_object_type2: '  || p_object_type2  );
       mydebug('p_object_id2: '  || p_object_id2  );
       mydebug('p_object_number2: '  || p_object_number2  );
       mydebug('p_parent_object_type2: '  || p_parent_object_type2  );
       mydebug('p_parent_object_id2: '   || p_parent_object_id2   );
       mydebug('p_parent_object_number2: '  || p_parent_object_number2  );
       mydebug('p_child_lot_control_code: '  || p_child_lot_control_code  );
       mydebug('p_parent_lot_control_code: '  || p_parent_lot_control_code  );
       mydebug('p_transaction_type: '  || p_transaction_type  );
    END IF;

    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    IF p_parent_object_type IS NULL THEN
         l_parent_object_type  := p_object_type;
    ELSE
         l_parent_object_type  := p_parent_object_type;
    END IF;

    IF p_parent_org_id IS NULL THEN
         l_parent_org_id  := p_organization_id;
    ELSE
         l_parent_org_id  := p_parent_org_id;
    END IF;

    l_action  := 'UPDATE';

    l_object_id2 := p_object_id2;
    l_parent_object_id2 := p_parent_object_id2;
    l_object_type2 := p_object_type2;
    l_parent_object_type2 := p_parent_object_type2;
    l_child_lot_control_code    := p_child_lot_control_code ;
    l_parent_lot_control_code   := p_parent_lot_control_code ;
    l_object_id := p_object_id;
    l_parent_object_id := p_parent_object_id;


    parameter_validations (
                               p_validation_level         =>   p_validation_level
                             , p_object_type              =>   p_object_type
                             , p_parent_object_type       =>   l_parent_object_type
                             , p_object_id                =>   l_object_id                 -- IN OUT
                             , p_object_number            =>   p_object_number
                             , p_inventory_item_id        =>   p_inventory_item_id
                             , p_org_id                   =>   p_organization_id
                             , p_parent_object_id         =>   l_parent_object_id          -- IN OUT
                             , p_parent_object_number     =>   p_parent_object_number
                             , p_parent_inventory_item_id =>   p_parent_inventory_item_id
                             , p_parent_org_id            =>   l_parent_org_id
                             , p_genealogy_origin         =>   p_genealogy_origin
                             , p_genealogy_type           =>   p_genealogy_type
                             , p_start_date_active        =>   p_start_date_active
                             , p_end_date_active          =>   p_end_date_active
                             , p_origin_txn_id            =>   p_origin_txn_id
                             , p_update_txn_id            =>   p_update_txn_id
                             , p_object_type2             =>   l_object_type2             -- IN OUT
                             , p_object_id2               =>   l_object_id2               -- IN OUT
                             , p_object_number2           =>   p_object_number2
                             , p_parent_object_type2      =>   l_parent_object_type2      -- IN OUT
                             , p_parent_object_id2        =>   l_parent_object_id2        -- IN OUT
                             , p_parent_object_number2    =>   p_parent_object_number2
                             , p_child_lot_control_code   =>   p_child_lot_control_code
                             , p_parent_lot_control_code  =>   p_parent_lot_control_code
                             , p_action                   =>   l_action
                             , p_debug                    =>   l_debug
                             , x_return_status            =>   l_return_status
                             , x_msg_count                =>   l_msg_count
                             , x_msg_data                 =>   l_msg_data);
         g_mod_name := 'update_Genealogy';

          IF (l_debug = 1) THEN
              mydebug('x_return_status from parameter_validations API: ' || x_return_status); END IF;

          IF x_return_status = lg_ret_sts_error
          THEN
             IF (l_debug = 1) THEN
                 mydebug('{{ If any of the parameter validations failed, then raise  ' ||
                          'an expected exception now..before inserting into genealogy }}' );
             END IF;
             RAISE lg_exc_error;
          END IF;
          IF x_return_status = lg_ret_sts_unexp_error
          THEN
             IF (l_debug = 1) THEN mydebug('{{ If any of the parameter validations failed, then raise  ' ||
                     'an unexpected exception now..before inserting into genealogy }}');
             END IF;
             RAISE lg_exc_unexpected_error;
          END IF;


    IF (l_debug = 1) THEN
       mydebug('After calling parameter validations, check the value of IN OUT parameters ' );
       mydebug('l_object_id                := ' || l_object_id );
       mydebug('l_parent_object_id         := ' || l_parent_object_id);
       mydebug('l_object_type2             := ' || l_object_type2);
       mydebug('l_object_id2               := ' || l_object_id2);
       mydebug('l_parent_object_type2      := ' || l_parent_object_type2) ;
       mydebug('l_parent_object_id2        := ' || l_parent_object_id2) ;
    END IF;


    IF p_end_date_active IS NULL THEN
       l_end_date_active  := SYSDATE;
    ELSE
       l_end_date_active  := p_end_date_active;
    END IF;

    IF (l_debug = 1) THEN
       mydebug('{{- Only if the relationship exists that it can be updated }}' );
       mydebug('{{- Check the end_date_active in the genealogy record is populated }} ');
    END IF ;
    /* 4997221: 02/02/2006: Added following logic for R12 assembly to job
     * relationship */
    IF p_transaction_type = 'ASSEMBLY_RETURN' THEN
       IF l_object_id2 IS NULL  THEN
          IF (l_debug = 1) THEN mydebug('{{- AR: Genealogy is not between lot+serial controlled items }}'); END IF;
          BEGIN
          UPDATE mtl_object_genealogy
          SET    last_update_date = SYSDATE
               , last_updated_by = -1
               , end_date_active = l_end_date_active
               , update_txn_id = p_update_txn_id
               , last_update_login = -1
               , request_id = -1
               , program_application_id = fnd_global.prog_appl_id
               , program_id = fnd_global.conc_program_id
               , program_update_date = SYSDATE
          WHERE end_date_active IS NULL
          AND parent_object_id = l_object_id
          AND parent_object_id2 IS NULL
          AND object_type = 5                 -- Job : 5368998
          AND object_id = l_parent_object_id  -- Job's gen object id : 5368998
          AND genealogy_type <> 5;
          /* 5368998: Added the above consition to make sure that only one
           * relation ship gets disabled. When assembly is completed, genealogy is created
           * between assembly and Job , so during assembly return only this genealogy
           * should be disabled */
          IF SQL%NOTFOUND THEN
             IF (l_debug = 1) THEN
                mydebug(' {{- AR: NO relationship between object_id and any other object :' || l_object_id || '}}');
             END IF;
          ELSE
             IF (l_debug = 1) THEN
                mydebug(' {{- AR: Number of relationships deleted for parent_object_id :'
                            || l_object_id || ' - IS:' || sql%rowcount || '}}');
             END IF;
          END IF;

          END ;
        ELSE
           IF (l_debug = 1) THEN
              mydebug(' {{- AR: Genealogy is between lot+serial child and non lot+serial parent }}');
           END IF;
           BEGIN
            UPDATE mtl_object_genealogy
            SET    last_update_date = SYSDATE
                 , last_updated_by = -1
                 , end_date_active = l_end_date_active
                 , update_txn_id = p_update_txn_id
                 , last_update_login = -1
                 , request_id = fnd_global.conc_request_id
                 , program_application_id = fnd_global.prog_appl_id
                 , program_id = fnd_global.conc_program_id
                 , program_update_date = SYSDATE
            WHERE end_date_active IS NULL
              AND parent_object_id = l_object_id
              AND parent_object_id2 = l_object_id2
              AND object_type = 5                 -- Job : 5368998
              AND object_id = l_parent_object_id  -- Job's gen object id : 5368998
              AND genealogy_type <> 5;
             IF SQL%NOTFOUND THEN
                IF (l_debug = 1) THEN
                  mydebug(' {{- AR: NO relationship between object_id,object_id2 and any other object :' || l_object_id
                          || ':' || l_object_id2 || '}}');
                END IF;
             ELSE
                IF (l_debug = 1) THEN
                  mydebug(' {{- AR: Number of relationships deleted for object_id ,object_id2 and any other object :'
                         || l_object_id || ':' || l_object_id2 || ' - IS:' || sql%rowcount || '}}');
                END IF;
             END IF;

           END ;
        END IF ;
    ELSE  -- IF p_transaction_type = 'COMP_RETURN'  OR NULL
       IF l_object_id2 IS NULL  THEN
          IF (l_debug = 1) THEN mydebug('{{- CR: Genealogy is not between lot+serial controlled items }}'); END IF;
          BEGIN
          UPDATE mtl_object_genealogy
          SET    last_update_date = SYSDATE
               , last_updated_by = -1
               , end_date_active = l_end_date_active
               , update_txn_id = p_update_txn_id
               , last_update_login = -1
               , request_id = -1
               , program_application_id = fnd_global.prog_appl_id
               , program_id = fnd_global.conc_program_id
               , program_update_date = SYSDATE
            WHERE end_date_active IS NULL
              AND object_id = l_object_id
              AND object_id2  IS NULL
              AND ( (parent_object_type = 5                      -- Job : 5368998
                     AND parent_object_id = l_parent_object_id)  -- Job's gen object id : 5368998
                   OR (parent_object_type <> 5))
              AND genealogy_type = 1;
              /* Bug: 5368998: Changed it from <>5 to =1, to make sure that only the genealogy
                  created by comp issue/assembly completion gets updated */
          IF SQL%NOTFOUND THEN
             IF (l_debug = 1) THEN
                mydebug(' {{- CR: NO relationship between object_id and any other object :' || l_object_id || '}}');
             END IF;
          ELSE
             IF (l_debug = 1) THEN
                mydebug(' {{- CR: Number of relationships deleted for parent_object_id :'
                            || l_object_id || ' - IS:' || sql%rowcount || '}}');
             END IF;
          END IF;

          END ;
        ELSE
           IF (l_debug = 1) THEN
              mydebug(' {{- CR: Genealogy is between lot+serial child and non lot+serial parent }}');
           END IF;
           BEGIN
            UPDATE mtl_object_genealogy
            SET    last_update_date = SYSDATE
                 , last_updated_by = -1
                 , end_date_active = l_end_date_active
                 , update_txn_id = p_update_txn_id
                 , last_update_login = -1
                 , request_id = fnd_global.conc_request_id
                 , program_application_id = fnd_global.prog_appl_id
                 , program_id = fnd_global.conc_program_id
                 , program_update_date = SYSDATE
            WHERE end_date_active IS NULL
              AND object_id = l_object_id
              AND object_id2 = l_object_id2
              AND ( (parent_object_type = 5                      -- Job : 5368998
                     AND parent_object_id = l_parent_object_id)  -- Job's gen object id : 5368998
                   OR (parent_object_type <> 5))
              AND genealogy_type = 1;
              /* Bug: 5368998: Changed it from <>5 to =1, to make sure that only the genealogy
                  created by comp issue/assembly completion gets updated */

             IF SQL%NOTFOUND THEN
                IF (l_debug = 1) THEN
                  mydebug(' {{- CR: NO relationship between object_id,object_id2 and any other object :' || l_object_id
                          || ':' || l_object_id2 || '}}');
                END IF;
             ELSE
                IF (l_debug = 1) THEN
                  mydebug(' {{- CR: Number of relationships deleted for object_id ,object_id2 and any other object :'
                         || l_object_id || ':' || l_object_id2 || ' - IS:' || sql%rowcount || '}}');
                END IF;
             END IF;

           END ;
        END IF ;
        UPDATE mtl_serial_numbers
        SET parent_serial_number = NULL
            ,last_update_date = SYSDATE
            ,last_updated_by = -1
            ,last_update_login = -1
        WHERE gen_object_id = l_object_id;

    END IF;

    IF (l_debug = 1) THEN mydebug('End of '|| g_mod_name); END IF;
  EXCEPTION
    WHEN lg_exc_error THEN
      IF (l_debug = 1) THEN mydebug('exception G_EXC_ERROR'|| x_msg_data); END IF;
      ROLLBACK TO save_update_genealogy;
      x_return_status  := lg_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);

    WHEN lg_exc_unexpected_error THEN
      IF (l_debug = 1) THEN mydebug('exception G_UNEXC_ERROR'|| x_msg_data); END IF;
      ROLLBACK TO save_update_genealogy;
      x_return_status  := lg_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN mydebug('exception WHEN OTHERS'|| x_msg_data); END IF;
      ROLLBACK TO save_update_genealogy;
      x_return_status  := lg_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => lg_fnd_g_false, p_count => x_msg_count, p_data => x_msg_data);
END update_genealogy;
END inv_genealogy_pub;

/

--------------------------------------------------------
--  DDL for Package Body INV_KANBANCARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_KANBANCARD_PKG" AS
  /* $Header: INVKCRDB.pls 120.5 2006/08/09 11:44:02 ankulkar noship $ */
  g_pkg_name              CONSTANT VARCHAR2(30)                  := 'INV_KanbanCard_PKG';

  TYPE supply_status_change_tbl_type IS TABLE OF VARCHAR2(1);

  g_true                  CONSTANT VARCHAR2(1)                   := fnd_api.g_true;
  g_false                 CONSTANT VARCHAR2(1)                   := fnd_api.g_false;
  g_supply_status_rows    CONSTANT NUMBER                        := 7;
  g_supply_status_columns CONSTANT NUMBER                        := 7;
  g_supply_status_change_tbl       supply_status_change_tbl_type
    := supply_status_change_tbl_type(
        g_true
      , g_true
      , g_true
      , g_true
      , g_false
      , g_false
      , g_false
      , g_false
      , g_true
      , g_true
      , g_true
      , g_false
      , g_false
      , g_false
      , g_false
      , g_false
      , g_true
      , g_true
      , g_false
      , g_false
      , g_false
      , g_false
      , g_true
      , g_false
      , g_true
      , g_true
      , g_false
      , g_false
      , g_false
      , g_true
      , g_false
      , g_false
      , g_true
      , g_true
      , g_true
      , g_false
      , g_true
      , g_false
      , g_false
      , g_false
      , g_true
      , g_false
      , g_false
      , g_true
      , g_false
      , g_false
      , g_false
      , g_false
      , g_true
      );

  PROCEDURE mydebug(msg IN VARCHAR2) IS
  BEGIN
    inv_trx_util_pub.TRACE(msg, 'INV_KANBANCARD_PKG', 9);
  END mydebug;

  FUNCTION check_unique(p_kanban_card_id IN OUT NOCOPY NUMBER, p_organization_id NUMBER, p_kanban_card_number VARCHAR2)
    RETURN BOOLEAN IS
    l_dummy VARCHAR2(1);
  BEGIN
    SELECT 'X'
      INTO l_dummy
      FROM mtl_kanban_cards
     WHERE organization_id = p_organization_id
       AND kanban_card_number = p_kanban_card_number
       AND((p_kanban_card_id IS NULL)
           OR(kanban_card_id <> p_kanban_card_id));

    RAISE TOO_MANY_ROWS;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN TRUE;
    WHEN OTHERS THEN
      fnd_message.set_name('INV', 'INV_KANBAN_CARD_NUM_EXISTS');
      fnd_message.set_token('CARD_NUMBER', p_kanban_card_number);
      RETURN FALSE;
  END check_unique;

  FUNCTION query_row(p_kanban_card_id IN NUMBER)
    RETURN inv_kanban_pvt.kanban_card_rec_type IS
    l_kanban_card_rec inv_kanban_pvt.kanban_card_rec_type;
  BEGIN
    SELECT kanban_card_id
         , kanban_card_number
         , pull_sequence_id
         , inventory_item_id
         , organization_id
         , subinventory_name
         , supply_status
         , card_status
         , kanban_card_type
         , source_type
         , kanban_size
         , last_update_date
         , last_updated_by
         , creation_date
         , created_by
         , locator_id
         , supplier_id
         , supplier_site_id
         , source_organization_id
         , source_subinventory
         , source_locator_id
         , wip_line_id
         , current_replnsh_cycle_id
         , ERROR_CODE
         , last_update_login
         , last_print_date
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
      INTO l_kanban_card_rec.kanban_card_id
         , l_kanban_card_rec.kanban_card_number
         , l_kanban_card_rec.pull_sequence_id
         , l_kanban_card_rec.inventory_item_id
         , l_kanban_card_rec.organization_id
         , l_kanban_card_rec.subinventory_name
         , l_kanban_card_rec.supply_status
         , l_kanban_card_rec.card_status
         , l_kanban_card_rec.kanban_card_type
         , l_kanban_card_rec.source_type
         , l_kanban_card_rec.kanban_size
         , l_kanban_card_rec.last_update_date
         , l_kanban_card_rec.last_updated_by
         , l_kanban_card_rec.creation_date
         , l_kanban_card_rec.created_by
         , l_kanban_card_rec.locator_id
         , l_kanban_card_rec.supplier_id
         , l_kanban_card_rec.supplier_site_id
         , l_kanban_card_rec.source_organization_id
         , l_kanban_card_rec.source_subinventory
         , l_kanban_card_rec.source_locator_id
         , l_kanban_card_rec.wip_line_id
         , l_kanban_card_rec.current_replnsh_cycle_id
         , l_kanban_card_rec.ERROR_CODE
         , l_kanban_card_rec.last_update_login
         , l_kanban_card_rec.last_print_date
         , l_kanban_card_rec.attribute_category
         , l_kanban_card_rec.attribute1
         , l_kanban_card_rec.attribute2
         , l_kanban_card_rec.attribute3
         , l_kanban_card_rec.attribute4
         , l_kanban_card_rec.attribute5
         , l_kanban_card_rec.attribute6
         , l_kanban_card_rec.attribute7
         , l_kanban_card_rec.attribute8
         , l_kanban_card_rec.attribute9
         , l_kanban_card_rec.attribute10
         , l_kanban_card_rec.attribute11
         , l_kanban_card_rec.attribute12
         , l_kanban_card_rec.attribute13
         , l_kanban_card_rec.attribute14
         , l_kanban_card_rec.attribute15
         , l_kanban_card_rec.request_id
         , l_kanban_card_rec.program_application_id
         , l_kanban_card_rec.program_id
         , l_kanban_card_rec.program_update_date
      FROM mtl_kanban_cards
     WHERE kanban_card_id = p_kanban_card_id;

    l_kanban_card_rec.document_type       := NULL;
    l_kanban_card_rec.document_header_id  := NULL;
    l_kanban_card_rec.document_detail_id  := NULL;
    RETURN l_kanban_card_rec;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Query_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END query_row;

  FUNCTION cell(row_in NUMBER, col_in NUMBER)
    RETURN NUMBER IS
  BEGIN
    RETURN (col_in - 1) * g_supply_status_rows + row_in;
  END cell;

  FUNCTION supply_status_change_ok(p_from_supply_status NUMBER, p_to_supply_status NUMBER, p_card_status NUMBER)
    RETURN BOOLEAN IS
    l_result             BOOLEAN;
    l_supply_status_from VARCHAR2(30);
    l_supply_status_to   VARCHAR2(30);
  BEGIN
    /*
    If p_card_status = INV_Kanban_PVT.G_Card_Status_Cancel
    Then
      FND_MESSAGE.SET_NAME('INV','INV_NO_ACT_ALLOW_CANCEL_CARD');
      Return False;
    Elsif p_card_status = INV_Kanban_PVT.G_Card_Status_Hold
    Then
      FND_MESSAGE.SET_NAME('INV','INV_NO_ACT_ALLOW_HOLD_CARD');
      Return False;
    Else
    */
    l_result  := fnd_api.to_boolean(g_supply_status_change_tbl(cell(p_to_supply_status, p_from_supply_status)));

    IF l_result THEN
      RETURN(l_result);
    END IF;

    BEGIN
      SELECT a.meaning
           , b.meaning
        INTO l_supply_status_from
           , l_supply_status_to
        FROM mfg_lookups a, mfg_lookups b
       WHERE a.lookup_type = 'MTL_KANBAN_SUPPLY_STATUS'
         AND a.lookup_code = p_from_supply_status
         AND b.lookup_type = 'MTL_KANBAN_SUPPLY_STATUS'
         AND b.lookup_code = p_to_supply_status;

      fnd_message.set_name('INV', 'INV_SUPPLY_STATUS_NOT_ALLOWED');
      fnd_message.set_token('SUPPLY_STATUS_FROM', l_supply_status_from);
      fnd_message.set_token('SUPPLY_STATUS_TO', l_supply_status_to);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    RETURN(l_result);
  /* End If; */
  END supply_status_change_ok;

  PROCEDURE commit_row IS
  BEGIN
    COMMIT;
  END commit_row;

  PROCEDURE rollback_row IS
  BEGIN
    ROLLBACK;
  END rollback_row;

  FUNCTION changed_row(p_kanban_card_rec inv_kanban_pvt.kanban_card_rec_type, p_old_kanban_card_rec inv_kanban_pvt.kanban_card_rec_type)
    RETURN BOOLEAN IS
    l_dupl_inprocess_act BOOLEAN  := ( p_kanban_card_rec.supply_status = p_old_kanban_card_rec.supply_status
                                      AND p_kanban_card_rec.supply_status = 5
                                      AND p_kanban_card_rec.current_replnsh_cycle_id = p_old_kanban_card_rec.current_replnsh_cycle_id
                                     );
  BEGIN
    -- Bug 3661982 : If the card is in 'In Process' state for a particular replenisment cycle,
    -- stop insertion into card activity table for another 'In Process' state activity if new
    -- replenisment cycle is identical to the old one.
    IF (
        p_kanban_card_rec.kanban_card_number = p_old_kanban_card_rec.kanban_card_number
        AND p_kanban_card_rec.pull_sequence_id = p_old_kanban_card_rec.pull_sequence_id
        AND p_kanban_card_rec.inventory_item_id = p_old_kanban_card_rec.inventory_item_id
        AND p_kanban_card_rec.organization_id = p_old_kanban_card_rec.organization_id
        AND p_kanban_card_rec.subinventory_name = p_old_kanban_card_rec.subinventory_name
        AND(
            (p_kanban_card_rec.supply_status = p_old_kanban_card_rec.supply_status
             AND p_kanban_card_rec.supply_status <> 5)
            OR l_dupl_inprocess_act
           )
        AND p_kanban_card_rec.card_status = p_old_kanban_card_rec.card_status
        AND p_kanban_card_rec.kanban_card_type = p_old_kanban_card_rec.kanban_card_type
        AND p_kanban_card_rec.source_type = p_old_kanban_card_rec.source_type
        AND p_kanban_card_rec.kanban_size = p_old_kanban_card_rec.kanban_size
        AND(
            (p_kanban_card_rec.last_print_date = p_old_kanban_card_rec.last_print_date)
            OR(p_kanban_card_rec.last_print_date IS NULL
               AND p_old_kanban_card_rec.last_print_date IS NULL)
           )
        AND(
            (p_kanban_card_rec.locator_id = p_old_kanban_card_rec.locator_id)
            OR(p_kanban_card_rec.locator_id IS NULL
               AND p_old_kanban_card_rec.locator_id IS NULL)
           )
        AND(
            (p_kanban_card_rec.supplier_id = p_old_kanban_card_rec.supplier_id)
            OR(p_kanban_card_rec.supplier_id IS NULL
               AND p_old_kanban_card_rec.supplier_id IS NULL)
           )
        AND(
            (p_kanban_card_rec.supplier_site_id = p_old_kanban_card_rec.supplier_site_id)
            OR(p_kanban_card_rec.supplier_site_id IS NULL
               AND p_old_kanban_card_rec.supplier_site_id IS NULL)
           )
        AND(
            (p_kanban_card_rec.source_organization_id = p_old_kanban_card_rec.source_organization_id)
            OR(p_kanban_card_rec.source_organization_id IS NULL
               AND p_old_kanban_card_rec.source_organization_id IS NULL)
           )
        AND(
            (p_kanban_card_rec.source_subinventory = p_old_kanban_card_rec.source_subinventory)
            OR(p_kanban_card_rec.source_subinventory IS NULL
               AND p_old_kanban_card_rec.source_subinventory IS NULL)
           )
        AND(
            (p_kanban_card_rec.source_locator_id = p_old_kanban_card_rec.source_locator_id)
            OR(p_kanban_card_rec.source_locator_id IS NULL
               AND p_old_kanban_card_rec.source_locator_id IS NULL)
           )
        AND(
            (p_kanban_card_rec.wip_line_id = p_old_kanban_card_rec.wip_line_id)
            OR(p_kanban_card_rec.wip_line_id IS NULL
               AND p_old_kanban_card_rec.wip_line_id IS NULL)
           )
        AND(
            (p_kanban_card_rec.ERROR_CODE = p_old_kanban_card_rec.ERROR_CODE)
            OR(p_kanban_card_rec.ERROR_CODE IS NULL
               AND p_old_kanban_card_rec.ERROR_CODE IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute_category = p_old_kanban_card_rec.attribute_category)
            OR(p_kanban_card_rec.attribute_category IS NULL
               AND p_old_kanban_card_rec.attribute_category IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute1 = p_old_kanban_card_rec.attribute1)
            OR(p_kanban_card_rec.attribute1 IS NULL
               AND p_old_kanban_card_rec.attribute1 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute2 = p_old_kanban_card_rec.attribute2)
            OR(p_kanban_card_rec.attribute2 IS NULL
               AND p_old_kanban_card_rec.attribute2 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute3 = p_old_kanban_card_rec.attribute3)
            OR(p_kanban_card_rec.attribute3 IS NULL
               AND p_old_kanban_card_rec.attribute3 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute4 = p_old_kanban_card_rec.attribute4)
            OR(p_kanban_card_rec.attribute4 IS NULL
               AND p_old_kanban_card_rec.attribute4 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute5 = p_old_kanban_card_rec.attribute5)
            OR(p_kanban_card_rec.attribute5 IS NULL
               AND p_old_kanban_card_rec.attribute5 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute6 = p_old_kanban_card_rec.attribute6)
            OR(p_kanban_card_rec.attribute6 IS NULL
               AND p_old_kanban_card_rec.attribute6 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute7 = p_old_kanban_card_rec.attribute7)
            OR(p_kanban_card_rec.attribute7 IS NULL
               AND p_old_kanban_card_rec.attribute7 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute8 = p_old_kanban_card_rec.attribute8)
            OR(p_kanban_card_rec.attribute8 IS NULL
               AND p_old_kanban_card_rec.attribute8 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute9 = p_old_kanban_card_rec.attribute9)
            OR(p_kanban_card_rec.attribute9 IS NULL
               AND p_old_kanban_card_rec.attribute9 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute10 = p_old_kanban_card_rec.attribute10)
            OR(p_kanban_card_rec.attribute10 IS NULL
               AND p_old_kanban_card_rec.attribute10 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute11 = p_old_kanban_card_rec.attribute11)
            OR(p_kanban_card_rec.attribute11 IS NULL
               AND p_old_kanban_card_rec.attribute11 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute12 = p_old_kanban_card_rec.attribute12)
            OR(p_kanban_card_rec.attribute12 IS NULL
               AND p_old_kanban_card_rec.attribute12 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute13 = p_old_kanban_card_rec.attribute13)
            OR(p_kanban_card_rec.attribute13 IS NULL
               AND p_old_kanban_card_rec.attribute13 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute14 = p_old_kanban_card_rec.attribute14)
            OR(p_kanban_card_rec.attribute14 IS NULL
               AND p_old_kanban_card_rec.attribute14 IS NULL)
           )
        AND(
            (p_kanban_card_rec.attribute15 = p_kanban_card_rec.attribute15)
            OR(p_kanban_card_rec.attribute15 IS NULL
               AND p_old_kanban_card_rec.attribute15 IS NULL)
           )
        AND((p_kanban_card_rec.document_type IS NULL)
            OR l_dupl_inprocess_act)
        AND((p_kanban_card_rec.document_header_id IS NULL)
            OR l_dupl_inprocess_act)
        AND((p_kanban_card_rec.document_detail_id IS NULL)
            OR l_dupl_inprocess_act)
        AND((p_kanban_card_rec.replenish_quantity IS NULL)
            OR l_dupl_inprocess_act)
       ) THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END changed_row;

  PROCEDURE insert_row(
    x_return_status            OUT NOCOPY    VARCHAR2
  , p_kanban_card_id           IN OUT NOCOPY NUMBER
  , p_kanban_card_number       IN OUT NOCOPY VARCHAR2
  , p_pull_sequence_id                       NUMBER
  , p_inventory_item_id                      NUMBER
  , p_organization_id                        NUMBER
  , p_subinventory_name                      VARCHAR2
  , p_supply_status            IN OUT NOCOPY NUMBER
  , p_card_status              IN OUT NOCOPY NUMBER
  , p_kanban_card_type                       NUMBER
  , p_source_type                            NUMBER
  , p_kanban_size                            NUMBER
  , p_last_update_date                       DATE
  , p_last_updated_by                        NUMBER
  , p_creation_date                          DATE
  , p_created_by                             NUMBER
  , p_last_update_login                      NUMBER
  , p_last_print_date                        DATE
  , p_locator_id                             NUMBER
  , p_supplier_id                            NUMBER
  , p_supplier_site_id                       NUMBER
  , p_source_organization_id                 NUMBER
  , p_source_subinventory                    VARCHAR2
  , p_source_locator_id                      NUMBER
  , p_wip_line_id                            NUMBER
  , p_current_replnsh_cycle_id IN OUT NOCOPY NUMBER
  , p_document_type                          NUMBER
  , p_document_header_id                     NUMBER
  , p_document_detail_id                     NUMBER
  , p_error_code                             NUMBER
  , p_attribute_category                     VARCHAR2
  , p_attribute1                             VARCHAR2
  , p_attribute2                             VARCHAR2
  , p_attribute3                             VARCHAR2
  , p_attribute4                             VARCHAR2
  , p_attribute5                             VARCHAR2
  , p_attribute6                             VARCHAR2
  , p_attribute7                             VARCHAR2
  , p_attribute8                             VARCHAR2
  , p_attribute9                             VARCHAR2
  , p_attribute10                            VARCHAR2
  , p_attribute11                            VARCHAR2
  , p_attribute12                            VARCHAR2
  , p_attribute13                            VARCHAR2
  , p_attribute14                            VARCHAR2
  , p_attribute15                            VARCHAR2
  , p_request_id                             NUMBER
  , p_program_application_id                 NUMBER
  , p_program_id                             NUMBER
  , p_program_update_date                    DATE
  , p_release_kanban_flag                    NUMBER
  ) IS
    l_kanban_card_rec          inv_kanban_pvt.kanban_card_rec_type;
    l_kanban_card_number_ok    BOOLEAN                             := FALSE;
    l_dummy                    VARCHAR2(1);
    l_return_status            VARCHAR2(1)                         := fnd_api.g_ret_sts_success;
    l_current_replnsh_cycle_id NUMBER;
    l_card_status              NUMBER;
    l_supply_status            NUMBER;
  BEGIN
    fnd_msg_pub.initialize;

    WHILE NOT l_kanban_card_number_ok LOOP
      SELECT mtl_kanban_cards_s.NEXTVAL
        INTO l_kanban_card_rec.kanban_card_id
        FROM DUAL;

      IF p_kanban_card_number IS NULL THEN
        BEGIN
          SELECT 'X'
            INTO l_dummy
            FROM mtl_kanban_cards
           WHERE kanban_card_number = TO_CHAR(l_kanban_card_rec.kanban_card_id)
             AND organization_id = p_organization_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_kanban_card_number_ok  := TRUE;
        END;
      ELSE
        l_kanban_card_number_ok  := TRUE;
      END IF;
    END LOOP;

    IF p_kanban_card_number IS NULL THEN
      l_kanban_card_rec.kanban_card_number  := TO_CHAR(l_kanban_card_rec.kanban_card_id);
    ELSE
      l_kanban_card_rec.kanban_card_number  := p_kanban_card_number;
    END IF;

    l_kanban_card_rec.pull_sequence_id          := p_pull_sequence_id;
    l_kanban_card_rec.inventory_item_id         := p_inventory_item_id;
    l_kanban_card_rec.organization_id           := p_organization_id;
    l_kanban_card_rec.subinventory_name         := p_subinventory_name;
    l_kanban_card_rec.supply_status             := p_supply_status;
    l_kanban_card_rec.card_status               := p_card_status;
    l_kanban_card_rec.kanban_card_type          := p_kanban_card_type;
    l_kanban_card_rec.source_type               := p_source_type;
    l_kanban_card_rec.kanban_size               := p_kanban_size;
    l_kanban_card_rec.last_update_date          := p_last_update_date;
    l_kanban_card_rec.last_updated_by           := p_last_updated_by;
    l_kanban_card_rec.creation_date             := p_creation_date;
    l_kanban_card_rec.created_by                := p_created_by;
    l_kanban_card_rec.last_update_login         := p_last_update_login;
    l_kanban_card_rec.last_print_date           := p_last_print_date;
    l_kanban_card_rec.locator_id                := p_locator_id;
    l_kanban_card_rec.supplier_id               := p_supplier_id;
    l_kanban_card_rec.supplier_site_id          := p_supplier_site_id;
    l_kanban_card_rec.source_organization_id    := p_source_organization_id;
    l_kanban_card_rec.source_subinventory       := p_source_subinventory;
    l_kanban_card_rec.source_locator_id         := p_source_locator_id;
    l_kanban_card_rec.wip_line_id               := p_wip_line_id;
    l_kanban_card_rec.current_replnsh_cycle_id  := p_current_replnsh_cycle_id;
    l_kanban_card_rec.document_type             := p_document_type;
    l_kanban_card_rec.document_header_id        := p_document_header_id;
    l_kanban_card_rec.document_detail_id        := p_document_detail_id;
    l_kanban_card_rec.ERROR_CODE                := p_error_code;
    l_kanban_card_rec.attribute_category        := p_attribute_category;
    l_kanban_card_rec.attribute1                := p_attribute1;
    l_kanban_card_rec.attribute2                := p_attribute2;
    l_kanban_card_rec.attribute3                := p_attribute3;
    l_kanban_card_rec.attribute4                := p_attribute4;
    l_kanban_card_rec.attribute5                := p_attribute5;
    l_kanban_card_rec.attribute6                := p_attribute6;
    l_kanban_card_rec.attribute7                := p_attribute7;
    l_kanban_card_rec.attribute8                := p_attribute8;
    l_kanban_card_rec.attribute9                := p_attribute9;
    l_kanban_card_rec.attribute10               := p_attribute10;
    l_kanban_card_rec.attribute11               := p_attribute11;
    l_kanban_card_rec.attribute12               := p_attribute12;
    l_kanban_card_rec.attribute13               := p_attribute13;
    l_kanban_card_rec.attribute14               := p_attribute14;
    l_kanban_card_rec.attribute15               := p_attribute15;
    l_kanban_card_rec.request_id                := p_request_id;
    l_kanban_card_rec.program_application_id    := p_program_application_id;
    l_kanban_card_rec.program_id                := p_program_id;
    l_kanban_card_rec.program_update_date       := p_program_update_date;

    INSERT INTO mtl_kanban_cards
                (
                 kanban_card_id
               , kanban_card_number
               , pull_sequence_id
               , inventory_item_id
               , organization_id
               , subinventory_name
               , supply_status
               , card_status
               , kanban_card_type
               , source_type
               , kanban_size
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , last_update_login
               , last_print_date
               , locator_id
               , supplier_id
               , supplier_site_id
               , source_organization_id
               , source_subinventory
               , source_locator_id
               , wip_line_id
               , current_replnsh_cycle_id
               , ERROR_CODE
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
                 l_kanban_card_rec.kanban_card_id
               , l_kanban_card_rec.kanban_card_number
               , l_kanban_card_rec.pull_sequence_id
               , l_kanban_card_rec.inventory_item_id
               , l_kanban_card_rec.organization_id
               , l_kanban_card_rec.subinventory_name
               , DECODE(
                   l_kanban_card_rec.supply_status
                 , inv_kanban_pvt.g_supply_status_empty, inv_kanban_pvt.g_supply_status_new
                 , l_kanban_card_rec.supply_status
                 )
               , l_kanban_card_rec.card_status
               , l_kanban_card_rec.kanban_card_type
               , l_kanban_card_rec.source_type
               , l_kanban_card_rec.kanban_size
               , l_kanban_card_rec.last_update_date
               , l_kanban_card_rec.last_updated_by
               , l_kanban_card_rec.creation_date
               , l_kanban_card_rec.created_by
               , l_kanban_card_rec.last_update_login
               , l_kanban_card_rec.last_print_date
               , l_kanban_card_rec.locator_id
               , l_kanban_card_rec.supplier_id
               , l_kanban_card_rec.supplier_site_id
               , l_kanban_card_rec.source_organization_id
               , l_kanban_card_rec.source_subinventory
               , l_kanban_card_rec.source_locator_id
               , l_kanban_card_rec.wip_line_id
               , l_kanban_card_rec.current_replnsh_cycle_id
               , l_kanban_card_rec.ERROR_CODE
               , l_kanban_card_rec.attribute_category
               , l_kanban_card_rec.attribute1
               , l_kanban_card_rec.attribute2
               , l_kanban_card_rec.attribute3
               , l_kanban_card_rec.attribute4
               , l_kanban_card_rec.attribute5
               , l_kanban_card_rec.attribute6
               , l_kanban_card_rec.attribute7
               , l_kanban_card_rec.attribute8
               , l_kanban_card_rec.attribute9
               , l_kanban_card_rec.attribute10
               , l_kanban_card_rec.attribute11
               , l_kanban_card_rec.attribute12
               , l_kanban_card_rec.attribute13
               , l_kanban_card_rec.attribute14
               , l_kanban_card_rec.attribute15
               , l_kanban_card_rec.request_id
               , l_kanban_card_rec.program_application_id
               , l_kanban_card_rec.program_id
               , l_kanban_card_rec.program_update_date
                );

    IF (
        (
         (l_kanban_card_rec.card_status = inv_kanban_pvt.g_card_status_active)
         AND(l_kanban_card_rec.supply_status = inv_kanban_pvt.g_supply_status_empty)
         AND(p_release_kanban_flag = 1)
        )
        OR(p_release_kanban_flag = 2)
       ) THEN
      l_supply_status                             := l_kanban_card_rec.supply_status;
      l_card_status                               := l_kanban_card_rec.card_status;
      l_current_replnsh_cycle_id                  := l_kanban_card_rec.current_replnsh_cycle_id;
      inv_kanbancard_pkg.update_row(
        x_return_status              => l_return_status
      , p_kanban_card_id             => l_kanban_card_rec.kanban_card_id
      , p_kanban_card_number         => l_kanban_card_rec.kanban_card_number
      , p_pull_sequence_id           => l_kanban_card_rec.pull_sequence_id
      , p_inventory_item_id          => l_kanban_card_rec.inventory_item_id
      , p_organization_id            => l_kanban_card_rec.organization_id
      , p_subinventory_name          => l_kanban_card_rec.subinventory_name
      , p_supply_status              => l_supply_status
      , p_card_status                => l_card_status
      , p_kanban_card_type           => l_kanban_card_rec.kanban_card_type
      , p_source_type                => l_kanban_card_rec.source_type
      , p_kanban_size                => l_kanban_card_rec.kanban_size
      , p_last_update_date           => l_kanban_card_rec.last_update_date
      , p_last_updated_by            => l_kanban_card_rec.last_updated_by
      , p_creation_date              => l_kanban_card_rec.creation_date
      , p_created_by                 => l_kanban_card_rec.created_by
      , p_last_update_login          => l_kanban_card_rec.last_update_login
      , p_last_print_date            => l_kanban_card_rec.last_print_date
      , p_locator_id                 => l_kanban_card_rec.locator_id
      , p_supplier_id                => l_kanban_card_rec.supplier_id
      , p_supplier_site_id           => l_kanban_card_rec.supplier_site_id
      , p_source_organization_id     => l_kanban_card_rec.source_organization_id
      , p_source_subinventory        => l_kanban_card_rec.source_subinventory
      , p_source_locator_id          => l_kanban_card_rec.source_locator_id
      , p_wip_line_id                => l_kanban_card_rec.wip_line_id
      , p_current_replnsh_cycle_id   => l_current_replnsh_cycle_id
      , p_document_type              => l_kanban_card_rec.document_type
      , p_document_header_id         => l_kanban_card_rec.document_header_id
      , p_document_detail_id         => l_kanban_card_rec.document_detail_id
      , p_error_code                 => l_kanban_card_rec.ERROR_CODE
      , p_attribute_category         => l_kanban_card_rec.attribute_category
      , p_attribute1                 => l_kanban_card_rec.attribute1
      , p_attribute2                 => l_kanban_card_rec.attribute2
      , p_attribute3                 => l_kanban_card_rec.attribute3
      , p_attribute4                 => l_kanban_card_rec.attribute4
      , p_attribute5                 => l_kanban_card_rec.attribute5
      , p_attribute6                 => l_kanban_card_rec.attribute6
      , p_attribute7                 => l_kanban_card_rec.attribute7
      , p_attribute8                 => l_kanban_card_rec.attribute8
      , p_attribute9                 => l_kanban_card_rec.attribute9
      , p_attribute10                => l_kanban_card_rec.attribute10
      , p_attribute11                => l_kanban_card_rec.attribute11
      , p_attribute12                => l_kanban_card_rec.attribute12
      , p_attribute13                => l_kanban_card_rec.attribute13
      , p_attribute14                => l_kanban_card_rec.attribute14
      , p_attribute15                => l_kanban_card_rec.attribute15
      );
      l_kanban_card_rec.supply_status             := l_supply_status;
      l_kanban_card_rec.card_status               := l_card_status;
      l_kanban_card_rec.current_replnsh_cycle_id  := l_current_replnsh_cycle_id;
    ELSE
      insert_activity_for_card(l_kanban_card_rec);
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    x_return_status                             := l_return_status;
    p_kanban_card_number                        := l_kanban_card_rec.kanban_card_number;
    p_kanban_card_id                            := l_kanban_card_rec.kanban_card_id;
    p_supply_status                             := l_kanban_card_rec.supply_status;
    p_card_status                               := l_kanban_card_rec.card_status;
    p_current_replnsh_cycle_id                  := l_kanban_card_rec.current_replnsh_cycle_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Insert_Row');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END insert_row;

  PROCEDURE lock_row(
    p_kanban_card_id           NUMBER
  , p_kanban_card_number       VARCHAR2
  , p_pull_sequence_id         NUMBER
  , p_inventory_item_id        NUMBER
  , p_organization_id          NUMBER
  , p_subinventory_name        VARCHAR2
  , p_supply_status            NUMBER
  , p_card_status              NUMBER
  , p_kanban_card_type         NUMBER
  , p_source_type              NUMBER
  , p_kanban_size              NUMBER
  , p_last_print_date          DATE
  , p_locator_id               NUMBER
  , p_supplier_id              NUMBER
  , p_supplier_site_id         NUMBER
  , p_source_organization_id   NUMBER
  , p_source_subinventory      VARCHAR2
  , p_source_locator_id        NUMBER
  , p_wip_line_id              NUMBER
  , p_current_replnsh_cycle_id NUMBER
  , p_error_code               NUMBER
  , p_attribute_category       VARCHAR2
  , p_attribute1               VARCHAR2
  , p_attribute2               VARCHAR2
  , p_attribute3               VARCHAR2
  , p_attribute4               VARCHAR2
  , p_attribute5               VARCHAR2
  , p_attribute6               VARCHAR2
  , p_attribute7               VARCHAR2
  , p_attribute8               VARCHAR2
  , p_attribute9               VARCHAR2
  , p_attribute10              VARCHAR2
  , p_attribute11              VARCHAR2
  , p_attribute12              VARCHAR2
  , p_attribute13              VARCHAR2
  , p_attribute14              VARCHAR2
  , p_attribute15              VARCHAR2
  ) IS
    CURSOR get_current_row IS
      SELECT        *
               FROM mtl_kanban_cards
              WHERE kanban_card_id = p_kanban_card_id
      FOR UPDATE OF organization_id NOWAIT;

    recinfo        mtl_kanban_cards%ROWTYPE;
    record_changed EXCEPTION;
  BEGIN
    OPEN get_current_row;
    FETCH get_current_row INTO recinfo;

    IF (get_current_row%NOTFOUND) THEN
      CLOSE get_current_row;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
    END IF;

    CLOSE get_current_row;

    IF NOT(
           recinfo.kanban_card_number = p_kanban_card_number
           AND recinfo.pull_sequence_id = p_pull_sequence_id
           AND recinfo.inventory_item_id = p_inventory_item_id
           AND recinfo.organization_id = p_organization_id
           AND recinfo.subinventory_name = p_subinventory_name
           AND recinfo.supply_status = p_supply_status
           AND recinfo.card_status = p_card_status
           AND recinfo.kanban_card_type = p_kanban_card_type
           AND recinfo.source_type = p_source_type
           AND recinfo.kanban_size = p_kanban_size
           AND((recinfo.last_print_date = p_last_print_date)
               OR(recinfo.last_print_date IS NULL
                  AND p_last_print_date IS NULL))
           AND((recinfo.locator_id = p_locator_id)
               OR(recinfo.locator_id IS NULL
                  AND p_locator_id IS NULL))
           AND((recinfo.supplier_id = p_supplier_id)
               OR(recinfo.supplier_id IS NULL
                  AND p_supplier_id IS NULL))
           AND((recinfo.supplier_site_id = p_supplier_site_id)
               OR(recinfo.supplier_site_id IS NULL
                  AND p_supplier_site_id IS NULL))
           AND(
               (recinfo.source_organization_id = p_source_organization_id)
               OR(recinfo.source_organization_id IS NULL
                  AND p_source_organization_id IS NULL)
              )
           AND(
               (recinfo.source_subinventory = p_source_subinventory)
               OR(recinfo.source_subinventory IS NULL
                  AND p_source_subinventory IS NULL)
              )
           AND((recinfo.source_locator_id = p_source_locator_id)
               OR(recinfo.source_locator_id IS NULL
                  AND p_source_locator_id IS NULL))
           AND((recinfo.wip_line_id = p_wip_line_id)
               OR(recinfo.wip_line_id IS NULL
                  AND p_wip_line_id IS NULL))
           AND((recinfo.ERROR_CODE = p_error_code)
               OR(recinfo.ERROR_CODE IS NULL
                  AND p_error_code IS NULL))
           AND((recinfo.attribute_category = p_attribute_category)
               OR(recinfo.attribute_category IS NULL
                  AND p_attribute_category IS NULL))
          ) THEN
      RAISE record_changed;
    END IF;

    IF NOT(
           ((recinfo.attribute1 = p_attribute1)
            OR((recinfo.attribute1 IS NULL)
               AND(p_attribute1 IS NULL)))
           AND((recinfo.attribute2 = p_attribute2)
               OR((recinfo.attribute2 IS NULL)
                  AND(p_attribute2 IS NULL)))
           AND((recinfo.attribute3 = p_attribute3)
               OR((recinfo.attribute3 IS NULL)
                  AND(p_attribute3 IS NULL)))
           AND((recinfo.attribute4 = p_attribute4)
               OR((recinfo.attribute4 IS NULL)
                  AND(p_attribute4 IS NULL)))
           AND((recinfo.attribute5 = p_attribute5)
               OR((recinfo.attribute5 IS NULL)
                  AND(p_attribute5 IS NULL)))
           AND((recinfo.attribute6 = p_attribute6)
               OR((recinfo.attribute6 IS NULL)
                  AND(p_attribute6 IS NULL)))
           AND((recinfo.attribute7 = p_attribute7)
               OR((recinfo.attribute7 IS NULL)
                  AND(p_attribute7 IS NULL)))
           AND((recinfo.attribute8 = p_attribute8)
               OR((recinfo.attribute8 IS NULL)
                  AND(p_attribute8 IS NULL)))
           AND((recinfo.attribute9 = p_attribute9)
               OR((recinfo.attribute9 IS NULL)
                  AND(p_attribute9 IS NULL)))
           AND((recinfo.attribute10 = p_attribute10)
               OR((recinfo.attribute10 IS NULL)
                  AND(p_attribute10 IS NULL)))
           AND((recinfo.attribute11 = p_attribute11)
               OR((recinfo.attribute11 IS NULL)
                  AND(p_attribute11 IS NULL)))
           AND((recinfo.attribute12 = p_attribute12)
               OR((recinfo.attribute12 IS NULL)
                  AND(p_attribute12 IS NULL)))
           AND((recinfo.attribute13 = p_attribute13)
               OR((recinfo.attribute13 IS NULL)
                  AND(p_attribute13 IS NULL)))
           AND((recinfo.attribute14 = p_attribute14)
               OR((recinfo.attribute14 IS NULL)
                  AND(p_attribute14 IS NULL)))
           AND((recinfo.attribute15 = p_attribute15)
               OR((recinfo.attribute15 IS NULL)
                  AND(p_attribute15 IS NULL)))
          ) THEN
      RAISE record_changed;
    END IF;
  EXCEPTION
    WHEN record_changed THEN
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      app_exception.raise_exception;
    WHEN OTHERS THEN
      RAISE;
  END lock_row;

  PROCEDURE update_row(
    x_return_status            OUT NOCOPY    VARCHAR2
  , p_kanban_card_id                         NUMBER
  , p_kanban_card_number                     VARCHAR2
  , p_pull_sequence_id                       NUMBER
  , p_inventory_item_id                      NUMBER
  , p_organization_id                        NUMBER
  , p_subinventory_name                      VARCHAR2
  , p_supply_status            IN OUT NOCOPY NUMBER
  , p_card_status              IN OUT NOCOPY NUMBER
  , p_kanban_card_type                       NUMBER
  , p_source_type                            NUMBER
  , p_kanban_size                            NUMBER
  , p_last_update_date                       DATE
  , p_last_updated_by                        NUMBER
  , p_creation_date                          DATE
  , p_created_by                             NUMBER
  , p_last_update_login                      NUMBER
  , p_last_print_date                        DATE
  , p_locator_id                             NUMBER
  , p_supplier_id                            NUMBER
  , p_supplier_site_id                       NUMBER
  , p_source_organization_id                 NUMBER
  , p_source_subinventory                    VARCHAR2
  , p_source_locator_id                      NUMBER
  , p_wip_line_id                            NUMBER
  , p_current_replnsh_cycle_id IN OUT NOCOPY NUMBER
  , p_document_type                          NUMBER
  , p_document_header_id                     NUMBER
  , p_document_detail_id                     NUMBER
  , p_error_code                             NUMBER
  , p_attribute_category                     VARCHAR2
  , p_attribute1                             VARCHAR2
  , p_attribute2                             VARCHAR2
  , p_attribute3                             VARCHAR2
  , p_attribute4                             VARCHAR2
  , p_attribute5                             VARCHAR2
  , p_attribute6                             VARCHAR2
  , p_attribute7                             VARCHAR2
  , p_attribute8                             VARCHAR2
  , p_attribute9                             VARCHAR2
  , p_attribute10                            VARCHAR2
  , p_attribute11                            VARCHAR2
  , p_attribute12                            VARCHAR2
  , p_attribute13                            VARCHAR2
  , p_attribute14                            VARCHAR2
  , p_attribute15                            VARCHAR2
  , p_lot_item_id                            NUMBER DEFAULT NULL
  , p_lot_number                             VARCHAR2 DEFAULT NULL
  , p_lot_item_revision                      VARCHAR2 DEFAULT NULL
  , p_lot_subinventory_code                  VARCHAR2 DEFAULT NULL
  , p_lot_location_id                        NUMBER DEFAULT NULL
  , p_lot_quantity                           NUMBER DEFAULT NULL
  , p_replenish_quantity                     NUMBER DEFAULT NULL
  , p_need_by_date                           DATE DEFAULT NULL
  , p_source_wip_entity_id                   NUMBER DEFAULT NULL
  ) IS
    l_kanban_card_rec            inv_kanban_pvt.kanban_card_rec_type;
    l_old_kanban_card_rec        inv_kanban_pvt.kanban_card_rec_type;
    l_current_replenish_cycle_id NUMBER;
    l_return_status              VARCHAR2(1)                         := fnd_api.g_ret_sts_success;
    l_supply_status              NUMBER;
  BEGIN
    fnd_msg_pub.initialize;
    mydebug('Inside update_row 2');
    l_old_kanban_card_rec                     := query_row(p_kanban_card_id => p_kanban_card_id);
    l_kanban_card_rec.kanban_card_id          := p_kanban_card_id;
    l_kanban_card_rec.kanban_card_number      := p_kanban_card_number;
    l_kanban_card_rec.pull_sequence_id        := p_pull_sequence_id;
    l_kanban_card_rec.inventory_item_id       := p_inventory_item_id;
    l_kanban_card_rec.organization_id         := p_organization_id;
    l_kanban_card_rec.subinventory_name       := p_subinventory_name;
    l_kanban_card_rec.kanban_card_type        := p_kanban_card_type;
    l_kanban_card_rec.supply_status           := p_supply_status;

    IF (l_kanban_card_rec.kanban_card_type = inv_kanban_pvt.g_card_type_nonreplenishable)
       AND(l_kanban_card_rec.supply_status = inv_kanban_pvt.g_supply_status_full)
       AND(l_old_kanban_card_rec.supply_status <> l_kanban_card_rec.supply_status) THEN
      l_kanban_card_rec.card_status  := inv_kanban_pvt.g_card_status_hold;
    ELSE
      l_kanban_card_rec.card_status  := p_card_status;
    END IF;

    l_kanban_card_rec.source_type             := p_source_type;
    l_kanban_card_rec.kanban_size             := p_kanban_size;
    l_kanban_card_rec.last_update_date        := p_last_update_date;
    l_kanban_card_rec.last_updated_by         := p_last_updated_by;
    l_kanban_card_rec.creation_date           := p_creation_date;
    l_kanban_card_rec.created_by              := p_created_by;
    l_kanban_card_rec.last_update_login       := p_last_update_login;
    l_kanban_card_rec.last_print_date         := p_last_print_date;
    l_kanban_card_rec.locator_id              := p_locator_id;
    l_kanban_card_rec.supplier_id             := p_supplier_id;
    l_kanban_card_rec.supplier_site_id        := p_supplier_site_id;
    l_kanban_card_rec.source_organization_id  := p_source_organization_id;
    l_kanban_card_rec.source_subinventory     := p_source_subinventory;
    l_kanban_card_rec.source_locator_id       := p_source_locator_id;
    l_kanban_card_rec.wip_line_id             := p_wip_line_id;
    l_kanban_card_rec.document_type           := p_document_type;
    l_kanban_card_rec.document_header_id      := p_document_header_id;
    l_kanban_card_rec.document_detail_id      := p_document_detail_id;

    IF p_supply_status = inv_kanban_pvt.g_supply_status_full THEN
      l_kanban_card_rec.current_replnsh_cycle_id  := NULL;
    ELSE
      l_kanban_card_rec.current_replnsh_cycle_id  := p_current_replnsh_cycle_id;
    END IF;

    l_kanban_card_rec.ERROR_CODE              := p_error_code;
    l_kanban_card_rec.attribute_category      := p_attribute_category;
    l_kanban_card_rec.attribute1              := p_attribute1;
    l_kanban_card_rec.attribute2              := p_attribute2;
    l_kanban_card_rec.attribute3              := p_attribute3;
    l_kanban_card_rec.attribute4              := p_attribute4;
    l_kanban_card_rec.attribute5              := p_attribute5;
    l_kanban_card_rec.attribute6              := p_attribute6;
    l_kanban_card_rec.attribute7              := p_attribute7;
    l_kanban_card_rec.attribute8              := p_attribute8;
    l_kanban_card_rec.attribute9              := p_attribute9;
    l_kanban_card_rec.attribute10             := p_attribute10;
    l_kanban_card_rec.attribute11             := p_attribute11;
    l_kanban_card_rec.attribute12             := p_attribute12;
    l_kanban_card_rec.attribute13             := p_attribute13;
    l_kanban_card_rec.attribute14             := p_attribute14;
    l_kanban_card_rec.attribute15             := p_attribute15;
    l_kanban_card_rec.lot_item_id             := p_lot_item_id;
    l_kanban_card_rec.lot_number              := p_lot_number;
    l_kanban_card_rec.lot_subinventory_code   := p_lot_subinventory_code;
    l_kanban_card_rec.lot_item_revision       := p_lot_item_revision;
    l_kanban_card_rec.lot_location_id         := p_lot_location_id;
    l_kanban_card_rec.lot_quantity            := p_lot_quantity;
    l_kanban_card_rec.replenish_quantity      := p_replenish_quantity;
    l_kanban_card_rec.need_by_date            := p_need_by_date;
    l_kanban_card_rec.source_wip_entity_id    := p_source_wip_entity_id;

    IF l_kanban_card_rec.card_status = inv_kanban_pvt.g_card_status_active
       AND l_kanban_card_rec.supply_status = inv_kanban_pvt.g_supply_status_empty
       AND l_old_kanban_card_rec.supply_status <> l_kanban_card_rec.supply_status THEN
      mydebug('calling INV_Kanban_PVT.Check_And_Create_Replenishment');
      inv_kanban_pvt.check_and_create_replenishment(
        x_return_status              => l_return_status
      , x_supply_status              => l_supply_status
      , x_current_replenish_cycle_id => l_current_replenish_cycle_id
      , p_kanban_card_rec            => l_kanban_card_rec
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_kanban_card_rec.supply_status             := l_supply_status;
      l_kanban_card_rec.current_replnsh_cycle_id  := l_current_replenish_cycle_id;
    END IF;

    UPDATE mtl_kanban_cards
       SET pull_sequence_id = l_kanban_card_rec.pull_sequence_id
         , inventory_item_id = l_kanban_card_rec.inventory_item_id
         , organization_id = l_kanban_card_rec.organization_id
         , subinventory_name = l_kanban_card_rec.subinventory_name
         , supply_status = l_kanban_card_rec.supply_status
         , card_status = l_kanban_card_rec.card_status
         , kanban_card_type = l_kanban_card_rec.kanban_card_type
         , source_type = l_kanban_card_rec.source_type
         , kanban_size = l_kanban_card_rec.kanban_size
         , last_update_date = l_kanban_card_rec.last_update_date
         , last_updated_by = l_kanban_card_rec.last_updated_by
         , creation_date = l_kanban_card_rec.creation_date
         , created_by = l_kanban_card_rec.created_by
         , last_update_login = l_kanban_card_rec.last_update_login
         , last_print_date = l_kanban_card_rec.last_print_date
         , locator_id = l_kanban_card_rec.locator_id
         , supplier_id = l_kanban_card_rec.supplier_id
         , supplier_site_id = l_kanban_card_rec.supplier_site_id
         , source_organization_id = l_kanban_card_rec.source_organization_id
         , source_subinventory = l_kanban_card_rec.source_subinventory
         , source_locator_id = l_kanban_card_rec.source_locator_id
         , wip_line_id = l_kanban_card_rec.wip_line_id
         , current_replnsh_cycle_id = l_kanban_card_rec.current_replnsh_cycle_id
         , ERROR_CODE = l_kanban_card_rec.ERROR_CODE
         , attribute_category = l_kanban_card_rec.attribute_category
         , attribute1 = l_kanban_card_rec.attribute1
         , attribute2 = l_kanban_card_rec.attribute2
         , attribute3 = l_kanban_card_rec.attribute3
         , attribute4 = l_kanban_card_rec.attribute4
         , attribute5 = l_kanban_card_rec.attribute5
         , attribute6 = l_kanban_card_rec.attribute6
         , attribute7 = l_kanban_card_rec.attribute7
         , attribute8 = l_kanban_card_rec.attribute8
         , attribute9 = l_kanban_card_rec.attribute9
         , attribute10 = l_kanban_card_rec.attribute10
         , attribute11 = l_kanban_card_rec.attribute11
         , attribute12 = l_kanban_card_rec.attribute12
         , attribute13 = l_kanban_card_rec.attribute13
         , attribute14 = l_kanban_card_rec.attribute14
         , attribute15 = l_kanban_card_rec.attribute15
     WHERE kanban_card_id = p_kanban_card_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    IF changed_row(l_kanban_card_rec, l_old_kanban_card_rec) THEN
      insert_activity_for_card(l_kanban_card_rec);
    -- Bug Fix 4361921
    ELSIF l_kanban_card_rec.document_type = INV_KANBAN_PVT.G_Doc_type_lot_job and
          l_kanban_card_rec.document_header_id <>
                  nvl( l_old_kanban_card_rec.document_header_id,-9999)  and
          l_kanban_card_rec.supply_status =
                               INV_KANBAN_PVT.G_Supply_Status_InProcess THEN
	      -- Bug Fix: 5344450
	      -- Added the IF condition
	      IF (p_replenish_quantity IS NULL) THEN

		 -- Retained old update statement.
	         mydebug(' Updating the document header id with :' ||
                               l_kanban_card_rec.document_header_id);
                 UPDATE mtl_kanban_card_activity
                 SET document_header_id = l_kanban_card_rec.document_header_id
                 WHERE
                 kanban_card_number = l_kanban_card_rec.kanban_card_number AND
                 supply_status = INV_KANBAN_PVT.G_Supply_Status_InProcess  AND
                 document_type = INV_KANBAN_PVT.G_Doc_type_lot_job AND
                 replenishment_cycle_id = l_kanban_card_rec.current_replnsh_cycle_id;
	      ELSE
	         -- Bug Fix: 5344450
		 -- Added new update statement to update the kanban_size with p_replenish_quantity
	         mydebug(' Updating the document header id with :' || l_kanban_card_rec.document_header_id||
		         ' kanban_size : '||p_replenish_quantity);
                 UPDATE mtl_kanban_card_activity
                 SET document_header_id = l_kanban_card_rec.document_header_id,
		 kanban_size = p_replenish_quantity
                 WHERE
                 kanban_card_number = l_kanban_card_rec.kanban_card_number AND
                 supply_status = INV_KANBAN_PVT.G_Supply_Status_InProcess  AND
                 document_type = INV_KANBAN_PVT.G_Doc_type_lot_job AND
                 replenishment_cycle_id = l_kanban_card_rec.current_replnsh_cycle_id;

	      END IF;

    END IF;

    x_return_status                           := l_return_status;
    p_supply_status                           := l_kanban_card_rec.supply_status;
    p_card_status                             := l_kanban_card_rec.card_status;
    p_current_replnsh_cycle_id                := l_kanban_card_rec.current_replnsh_cycle_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'update_row');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END update_row;

  PROCEDURE update_row(p_kanban_card_rec inv_kanban_pvt.kanban_card_rec_type) IS
    l_return_status            VARCHAR2(1);
    l_supply_status            NUMBER;
    l_card_status              NUMBER;
    l_current_replnsh_cycle_id NUMBER;
  BEGIN
    fnd_msg_pub.initialize;
    mydebug('Inside update_row 1');
    l_supply_status             := p_kanban_card_rec.supply_status;
    l_card_status               := p_kanban_card_rec.card_status;
    l_current_replnsh_cycle_id  := p_kanban_card_rec.current_replnsh_cycle_id;
    update_row(
      x_return_status              => l_return_status
    , p_kanban_card_id             => p_kanban_card_rec.kanban_card_id
    , p_kanban_card_number         => p_kanban_card_rec.kanban_card_number
    , p_pull_sequence_id           => p_kanban_card_rec.pull_sequence_id
    , p_inventory_item_id          => p_kanban_card_rec.inventory_item_id
    , p_organization_id            => p_kanban_card_rec.organization_id
    , p_subinventory_name          => p_kanban_card_rec.subinventory_name
    , p_supply_status              => l_supply_status
    , p_card_status                => l_card_status
    , p_kanban_card_type           => p_kanban_card_rec.kanban_card_type
    , p_source_type                => p_kanban_card_rec.source_type
    , p_kanban_size                => p_kanban_card_rec.kanban_size
    , p_last_update_date           => p_kanban_card_rec.last_update_date
    , p_last_updated_by            => p_kanban_card_rec.last_updated_by
    , p_creation_date              => p_kanban_card_rec.creation_date
    , p_created_by                 => p_kanban_card_rec.created_by
    , p_last_update_login          => p_kanban_card_rec.last_update_login
    , p_last_print_date            => p_kanban_card_rec.last_print_date
    , p_locator_id                 => p_kanban_card_rec.locator_id
    , p_supplier_id                => p_kanban_card_rec.supplier_id
    , p_supplier_site_id           => p_kanban_card_rec.supplier_site_id
    , p_source_organization_id     => p_kanban_card_rec.source_organization_id
    , p_source_subinventory        => p_kanban_card_rec.source_subinventory
    , p_source_locator_id          => p_kanban_card_rec.source_locator_id
    , p_wip_line_id                => p_kanban_card_rec.wip_line_id
    , p_current_replnsh_cycle_id   => l_current_replnsh_cycle_id
    , p_document_type              => p_kanban_card_rec.document_type
    , p_document_header_id         => p_kanban_card_rec.document_header_id
    , p_document_detail_id         => p_kanban_card_rec.document_detail_id
    , p_error_code                 => p_kanban_card_rec.ERROR_CODE
    , p_attribute_category         => p_kanban_card_rec.attribute_category
    , p_attribute1                 => p_kanban_card_rec.attribute1
    , p_attribute2                 => p_kanban_card_rec.attribute2
    , p_attribute3                 => p_kanban_card_rec.attribute3
    , p_attribute4                 => p_kanban_card_rec.attribute4
    , p_attribute5                 => p_kanban_card_rec.attribute5
    , p_attribute6                 => p_kanban_card_rec.attribute6
    , p_attribute7                 => p_kanban_card_rec.attribute7
    , p_attribute8                 => p_kanban_card_rec.attribute8
    , p_attribute9                 => p_kanban_card_rec.attribute9
    , p_attribute10                => p_kanban_card_rec.attribute10
    , p_attribute11                => p_kanban_card_rec.attribute11
    , p_attribute12                => p_kanban_card_rec.attribute12
    , p_attribute13                => p_kanban_card_rec.attribute13
    , p_attribute14                => p_kanban_card_rec.attribute14
    , p_attribute15                => p_kanban_card_rec.attribute15
    , p_lot_item_id                => p_kanban_card_rec.lot_item_id
    , p_lot_number                 => p_kanban_card_rec.lot_number
    , p_lot_subinventory_code      => p_kanban_card_rec.lot_subinventory_code
    , p_lot_item_revision          => p_kanban_card_rec.lot_item_revision
    , p_lot_location_id            => p_kanban_card_rec.lot_location_id
    , p_lot_quantity               => p_kanban_card_rec.lot_quantity
    , p_replenish_quantity         => p_kanban_card_rec.replenish_quantity
    , p_need_by_date               => p_kanban_card_rec.need_by_date
    , p_source_wip_entity_id       => p_kanban_card_rec.source_wip_entity_id
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Update_Row');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END update_row;

  PROCEDURE update_card_status(p_kanban_card_rec IN OUT NOCOPY inv_kanban_pvt.kanban_card_rec_type, p_card_status IN NUMBER) IS
    l_return_status VARCHAR2(1);
    l_card_status   NUMBER;
  BEGIN
    fnd_msg_pub.initialize;
    l_card_status  := p_card_status;
    update_row(
      x_return_status              => l_return_status
    , p_kanban_card_id             => p_kanban_card_rec.kanban_card_id
    , p_kanban_card_number         => p_kanban_card_rec.kanban_card_number
    , p_pull_sequence_id           => p_kanban_card_rec.pull_sequence_id
    , p_inventory_item_id          => p_kanban_card_rec.inventory_item_id
    , p_organization_id            => p_kanban_card_rec.organization_id
    , p_subinventory_name          => p_kanban_card_rec.subinventory_name
    , p_supply_status              => p_kanban_card_rec.supply_status
    , p_card_status                => l_card_status
    , p_kanban_card_type           => p_kanban_card_rec.kanban_card_type
    , p_source_type                => p_kanban_card_rec.source_type
    , p_kanban_size                => p_kanban_card_rec.kanban_size
    , p_last_update_date           => p_kanban_card_rec.last_update_date
    , p_last_updated_by            => p_kanban_card_rec.last_updated_by
    , p_creation_date              => p_kanban_card_rec.creation_date
    , p_created_by                 => p_kanban_card_rec.created_by
    , p_last_update_login          => p_kanban_card_rec.last_update_login
    , p_last_print_date            => p_kanban_card_rec.last_print_date
    , p_locator_id                 => p_kanban_card_rec.locator_id
    , p_supplier_id                => p_kanban_card_rec.supplier_id
    , p_supplier_site_id           => p_kanban_card_rec.supplier_site_id
    , p_source_organization_id     => p_kanban_card_rec.source_organization_id
    , p_source_subinventory        => p_kanban_card_rec.source_subinventory
    , p_source_locator_id          => p_kanban_card_rec.source_locator_id
    , p_wip_line_id                => p_kanban_card_rec.wip_line_id
    , p_current_replnsh_cycle_id   => p_kanban_card_rec.current_replnsh_cycle_id
    , p_document_type              => p_kanban_card_rec.document_type
    , p_document_header_id         => p_kanban_card_rec.document_header_id
    , p_document_detail_id         => p_kanban_card_rec.document_detail_id
    , p_error_code                 => p_kanban_card_rec.ERROR_CODE
    , p_attribute_category         => p_kanban_card_rec.attribute_category
    , p_attribute1                 => p_kanban_card_rec.attribute1
    , p_attribute2                 => p_kanban_card_rec.attribute2
    , p_attribute3                 => p_kanban_card_rec.attribute3
    , p_attribute4                 => p_kanban_card_rec.attribute4
    , p_attribute5                 => p_kanban_card_rec.attribute5
    , p_attribute6                 => p_kanban_card_rec.attribute6
    , p_attribute7                 => p_kanban_card_rec.attribute7
    , p_attribute8                 => p_kanban_card_rec.attribute8
    , p_attribute9                 => p_kanban_card_rec.attribute9
    , p_attribute10                => p_kanban_card_rec.attribute10
    , p_attribute11                => p_kanban_card_rec.attribute11
    , p_attribute12                => p_kanban_card_rec.attribute12
    , p_attribute13                => p_kanban_card_rec.attribute13
    , p_attribute14                => p_kanban_card_rec.attribute14
    , p_attribute15                => p_kanban_card_rec.attribute15
    );

    IF l_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      RAISE fnd_api.g_exc_unexpected_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Update_Card_Status');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END update_card_status;

  PROCEDURE delete_row(x_return_status OUT NOCOPY VARCHAR2, p_kanban_card_id NUMBER) IS
    l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
  BEGIN
    DELETE FROM mtl_kanban_cards
          WHERE kanban_card_id = p_kanban_card_id;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    delete_activity_for_card(p_kanban_card_id);
    x_return_status  := l_return_status;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Delete_Row');
      END IF;

      x_return_status  := fnd_api.g_ret_sts_unexp_error;
  END delete_row;

  PROCEDURE insert_activity_for_card(p_kanban_card_rec IN inv_kanban_pvt.kanban_card_rec_type) IS
  BEGIN
    INSERT INTO mtl_kanban_card_activity
                (
                 kanban_activity_id
               , replenishment_cycle_id
               , kanban_card_id
               , kanban_card_number
               , inventory_item_id
               , organization_id
               , subinventory_name
               , supply_status
               , card_status
               , kanban_card_type
               , source_type
               , kanban_size
               , last_update_date
               , last_updated_by
               , creation_date
               , created_by
               , locator_id
               , supplier_id
               , supplier_site_id
               , source_organization_id
               , source_subinventory
               , source_locator_id
               , wip_line_id
               , document_type
               , document_header_id
               , document_detail_id
               , ERROR_CODE
               , last_update_login
               , last_print_date
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
               , source_wip_entity_id
                )
         VALUES (
                 mtl_kanban_card_activity_s.NEXTVAL
               , NVL(p_kanban_card_rec.current_replnsh_cycle_id, -1)
               , p_kanban_card_rec.kanban_card_id
               , p_kanban_card_rec.kanban_card_number
               , p_kanban_card_rec.inventory_item_id
               , p_kanban_card_rec.organization_id
               , p_kanban_card_rec.subinventory_name
               , p_kanban_card_rec.supply_status
               , p_kanban_card_rec.card_status
               , p_kanban_card_rec.kanban_card_type
               , p_kanban_card_rec.source_type
               , NVL(p_kanban_card_rec.replenish_quantity, p_kanban_card_rec.kanban_size)
               , SYSDATE
               , fnd_global.user_id
               , SYSDATE
               , fnd_global.user_id
               , p_kanban_card_rec.locator_id
               , p_kanban_card_rec.supplier_id
               , p_kanban_card_rec.supplier_site_id
               , p_kanban_card_rec.source_organization_id
               , p_kanban_card_rec.source_subinventory
               , p_kanban_card_rec.source_locator_id
               , p_kanban_card_rec.wip_line_id
               , p_kanban_card_rec.document_type
               , p_kanban_card_rec.document_header_id
               , p_kanban_card_rec.document_detail_id
               , p_kanban_card_rec.ERROR_CODE
               , fnd_global.login_id
               , p_kanban_card_rec.last_print_date
               , p_kanban_card_rec.attribute_category
               , p_kanban_card_rec.attribute1
               , p_kanban_card_rec.attribute2
               , p_kanban_card_rec.attribute3
               , p_kanban_card_rec.attribute4
               , p_kanban_card_rec.attribute5
               , p_kanban_card_rec.attribute6
               , p_kanban_card_rec.attribute7
               , p_kanban_card_rec.attribute8
               , p_kanban_card_rec.attribute9
               , p_kanban_card_rec.attribute10
               , p_kanban_card_rec.attribute11
               , p_kanban_card_rec.attribute12
               , p_kanban_card_rec.attribute13
               , p_kanban_card_rec.attribute14
               , p_kanban_card_rec.attribute15
               , p_kanban_card_rec.request_id
               , p_kanban_card_rec.program_application_id
               , p_kanban_card_rec.program_id
               , p_kanban_card_rec.program_update_date
               , p_kanban_card_rec.source_wip_entity_id
                );
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Insert_Activity_For_Card');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END insert_activity_for_card;

  PROCEDURE delete_cards_for_pull_seq(p_pull_sequence_id NUMBER) IS
  BEGIN
    inv_kanbancard_pkg.delete_activity_for_pull_seq(p_pull_sequence_id);

    DELETE FROM mtl_kanban_cards
          WHERE pull_sequence_id = p_pull_sequence_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Delete_Cards_For_Pull_Seq');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END delete_cards_for_pull_seq;

  PROCEDURE delete_activity_for_card(p_kanban_card_id NUMBER) IS
  BEGIN
    DELETE FROM mtl_kanban_card_activity
          WHERE kanban_card_id = p_kanban_card_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Delete_Activity_For_Card');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END delete_activity_for_card;

  PROCEDURE delete_activity_for_pull_seq(p_pull_sequence_id NUMBER) IS
  BEGIN
    DELETE FROM mtl_kanban_card_activity act
          WHERE EXISTS(SELECT 'x'
                         FROM mtl_kanban_cards crd
                        WHERE crd.kanban_card_id = act.kanban_card_id
                          AND crd.pull_sequence_id = p_pull_sequence_id);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      RAISE fnd_api.g_exc_error;
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'Delete_Activity_For_Pull_Seq');
      END IF;

      RAISE fnd_api.g_exc_unexpected_error;
  END delete_activity_for_pull_seq;
END inv_kanbancard_pkg;

/

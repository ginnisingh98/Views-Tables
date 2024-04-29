--------------------------------------------------------
--  DDL for Package Body WMS_CONTAINER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CONTAINER_PUB" AS
/* $Header: WMSCONTB.pls 120.5.12010000.5 2010/01/28 11:33:50 schiluve ship $ */

--  Global constant holding the package name
g_pkg_name CONSTANT VARCHAR2(30)     := 'WMS_CONTAINER_PUB';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSCONTB.pls 120.5.12010000.5 2010/01/28 11:33:50 schiluve ship $';

--  Global value storing the transaction histories for pack/unpack operations
g_history_table     transaction_history;

-- Various debug levels
G_ERROR           CONSTANT NUMBER := 1;
G_INFO      CONSTANT NUMBER := 5;
G_MESSAGE   CONSTANT NUMBER := 9;

  PROCEDURE mdebug(msg IN VARCHAR2, LEVEL NUMBER := G_MESSAGE) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    --DBMS_OUTPUT.put_line(msg);
    IF (l_debug = 1) THEN
       inv_trx_util_pub.TRACE(msg, 'WMS_CONTAINER_PUB', LEVEL);
    END IF;
    NULL;
  END;

  /*Bug#2200989. Added local procedure to update the wt and volume
    of the LPNs in shipping when the corrosponding LPN is modified
    in WMS_LICENSE_PLATE_NUMBERS. */

  PROCEDURE update_shipping_details(p_lpn_id IN NUMBER, p_gross_weight IN NUMBER, p_net_weight IN NUMBER, p_weight_uom IN VARCHAR2, p_volume IN NUMBER, p_volume_uom IN VARCHAR2) IS
    CURSOR wsh_lpn_id IS
      SELECT 1
        FROM wsh_delivery_details
       WHERE lpn_id = p_lpn_id;

    --Bug 5190145
    --Added following cursor to get inventory_item_id from WLPN
    CURSOR lpn_item_id IS
      SELECT nvl(inventory_item_id, -99999)
      FROM wms_license_plate_numbers
      WHERE lpn_id = p_lpn_id;

    x_return_status      VARCHAR2(10);
    x_msg_count          NUMBER;
    x_msg_data           VARCHAR2(6000);
    l_container_name     VARCHAR2(30);
    l_dummy              NUMBER;
    l_delivery_detail_id NUMBER;
    l_api_version        NUMBER                                           := 1.0;

    --Begin bug 5190145
    --changed to call WSH_container_grp api
    --l_changed_attributes wsh_delivery_details_pub.changedattributerectype;
    l_changed_attributes WSH_CONTAINER_GRP.CHANGEDATTRIBUTETABTYPE;
    l_lpn_item_id        NUMBER := -99999;
    --End Bug 5190145

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    OPEN wsh_lpn_id;
    FETCH wsh_lpn_id INTO l_dummy;

    IF wsh_lpn_id%FOUND THEN
      SELECT delivery_detail_id,
             container_name
        INTO l_delivery_detail_id,
             l_container_name
        FROM wsh_delivery_details
       WHERE lpn_id = p_lpn_id;


       --Begin bug 5190145
       OPEN lpn_item_id;
    	FETCH lpn_item_id INTO l_lpn_item_id;
	CLOSE lpn_item_id;

      l_changed_attributes(1).delivery_detail_id  := l_delivery_detail_id;
      l_changed_attributes(1).container_name      := l_container_name;
      l_changed_attributes(1).net_weight          := p_net_weight;
      l_changed_attributes(1).gross_weight        := p_gross_weight;
      l_changed_attributes(1).weight_uom_code     := p_weight_uom;
      l_changed_attributes(1).volume              := p_volume;
      l_changed_attributes(1).volume_uom_code     := p_volume_uom;
      IF (l_lpn_item_id <> -99999) THEN
         l_changed_attributes(1).inventory_item_id   := l_lpn_item_id;
      END IF;

      IF (l_debug = 1) THEN
         mdebug('***in Update Shipping Details proc***');
         mdebug('***delivery_detail_id='|| l_delivery_detail_id);
         mdebug('***container_name='|| l_container_name);
         mdebug('***net weight='|| p_net_weight);
         mdebug('***gross_weight='|| p_gross_weight);
         mdebug('***weight_uom_code='|| p_weight_uom);
         mdebug('***volume='|| p_volume);
         mdebug('***volume_uom_code='|| p_volume_uom);
         mdebug('***l_lpn_item_id='|| l_lpn_item_id);
      END IF;
      --Call the Shipping API to update Container details.
      wsh_container_grp.update_container(l_api_version, fnd_api.g_false,fnd_api.g_false,fnd_api.g_valid_level_full, x_return_status, x_msg_count, x_msg_data, l_changed_attributes);
      -- End bug 5190145
    END IF;


    CLOSE wsh_lpn_id;
  END update_shipping_details;


PROCEDURE Generate_LPN (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_container_item_id      IN         NUMBER   := NULL
, p_revision               IN         VARCHAR2 := NULL
, p_lot_number             IN         VARCHAR2 := NULL
, p_from_serial_number     IN         VARCHAR2 := NULL
, p_to_serial_number       IN         VARCHAR2 := NULL
, p_subinventory           IN         VARCHAR2 := NULL
, p_locator_id             IN         NUMBER   := NULL
, p_lpn_prefix             IN         VARCHAR2 := NULL
, p_lpn_suffix             IN         VARCHAR2 := NULL
, p_starting_num           IN         NUMBER   := NULL
, p_quantity               IN         NUMBER   := 1
, p_source                 IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id          IN         NUMBER   := NULL
, p_source_type_id         IN         NUMBER   := NULL
, p_source_header_id       IN         NUMBER   := NULL
, p_source_name            IN         VARCHAR2 := NULL
, p_source_line_id         IN         NUMBER   := NULL
, p_source_line_detail_id  IN         NUMBER   := NULL
, p_total_length           IN         NUMBER   := NULL
, p_ucc_128_suffix_flag    IN         VARCHAR2 := NULL
, p_lpn_id_out             OUT NOCOPY NUMBER
, p_lpn_out                OUT NOCOPY VARCHAR2
, p_process_id             OUT NOCOPY NUMBER
) IS
BEGIN
Generate_LPN (
  p_api_version           =>	p_api_version
, p_init_msg_list         =>	p_init_msg_list
, p_commit                =>	p_commit
, p_validation_level      =>	p_validation_level
, x_return_status         =>	x_return_status
, x_msg_count             =>	x_msg_count
, x_msg_data              =>	x_msg_data
, p_organization_id       =>	p_organization_id
, p_container_item_id     =>	p_container_item_id
, p_revision              =>	p_revision
, p_lot_number            =>	p_lot_number
, p_from_serial_number    =>	p_from_serial_number
, p_to_serial_number      =>	p_to_serial_number
, p_subinventory          =>	p_subinventory
, p_locator_id            =>	p_locator_id
, p_lpn_prefix            =>	p_lpn_prefix
, p_lpn_suffix            =>	p_lpn_suffix
, p_starting_num          =>	p_starting_num
, p_quantity              =>	p_quantity
, p_source                =>	p_source
, p_cost_group_id         =>	p_cost_group_id
, p_source_type_id        =>	p_source_type_id
, p_source_header_id      =>	p_source_header_id
, p_source_name           =>	p_source_name
, p_source_line_id        =>	p_source_line_id
, p_source_line_detail_id =>	p_source_line_detail_id
, p_lpn_id_out            =>	p_lpn_id_out
, p_lpn_out               =>	p_lpn_out
, p_process_id            =>	p_process_id
, p_total_length          =>	p_total_length
, p_ucc_128_suffix_flag   =>	p_ucc_128_suffix_flag
, p_client_code		  =>	NULL
);

END Generate_LPN;

-- Overloaded for LSP, bug 9087971

PROCEDURE Generate_LPN (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_organization_id        IN         NUMBER
, p_container_item_id      IN         NUMBER   := NULL
, p_revision               IN         VARCHAR2 := NULL
, p_lot_number             IN         VARCHAR2 := NULL
, p_from_serial_number     IN         VARCHAR2 := NULL
, p_to_serial_number       IN         VARCHAR2 := NULL
, p_subinventory           IN         VARCHAR2 := NULL
, p_locator_id             IN         NUMBER   := NULL
, p_lpn_prefix             IN         VARCHAR2 := NULL
, p_lpn_suffix             IN         VARCHAR2 := NULL
, p_starting_num           IN         NUMBER   := NULL
, p_quantity               IN         NUMBER   := 1
, p_source                 IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id          IN         NUMBER   := NULL
, p_source_type_id         IN         NUMBER   := NULL
, p_source_header_id       IN         NUMBER   := NULL
, p_source_name            IN         VARCHAR2 := NULL
, p_source_line_id         IN         NUMBER   := NULL
, p_source_line_detail_id  IN         NUMBER   := NULL
, p_total_length           IN         NUMBER   := NULL
, p_ucc_128_suffix_flag    IN         VARCHAR2 := NULL
, p_lpn_id_out             OUT NOCOPY NUMBER
, p_lpn_out                OUT NOCOPY VARCHAR2
, p_process_id             OUT NOCOPY NUMBER
, p_client_code	           IN         VARCHAR2 -- Adding for LSP  , bug 9087971
) IS
l_api_name    CONSTANT VARCHAR2(30)  := 'Generate_LPN';
l_api_version CONSTANT NUMBER        := 1.0;
l_debug                NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(500) := 'Entered API';
l_msgdata              VARCHAR2(1000);

-- Variables use by Auto_Create_LPNs
l_lpn_att_rec  WMS_Data_Type_Definitions_PUB.LPNRecordType;
l_serial_tbl   WMS_Data_Type_Definitions_PUB.SerialRangeTableType;
l_gen_lpn_tbl  WMS_Data_Type_Definitions_PUB.LPNTableType;
l_lpn_bulk_rec WMS_CONTAINER_PVT.LPNBulkRecType;

-- Validation Parameters
l_quantity             NUMBER;
l_org                  inv_validate.org;
l_container_item       inv_validate.item;
l_lpn                  lpn;
l_sub                  inv_validate.sub;
l_locator              inv_validate.LOCATOR;
l_lot                  inv_validate.lot;
l_serial               inv_validate.serial;
l_current_serial       VARCHAR2(30)                             := p_from_serial_number;
l_prefix               VARCHAR2(30);
l_quantity_serial      NUMBER;
l_from_number          NUMBER;
l_to_number            NUMBER;
l_errorcode            NUMBER;
l_length               NUMBER;
l_padded_length        NUMBER;
l_current_number       NUMBER;
l_result               NUMBER;

/* FP-J Lot/Serial Support Enhancements
 * Add current status of resides in receiving
 */
CURSOR serial_validation_cursor IS
  SELECT 'Validate-Serial'
    FROM DUAL
   WHERE EXISTS( SELECT 'Subinventory-not-given'
                   FROM mtl_serial_numbers
                  WHERE inventory_item_id = p_container_item_id
                    AND current_organization_id = p_organization_id
                    AND serial_number = l_current_serial
                    AND current_status IN (1, 5, 6, 7));

l_serial_validate      VARCHAR2(15);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT GENERATE_LPN_PUB;

  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;
  -- API body
  IF (l_debug = 1) THEN
    mdebug('Call to Generate_LPN orgid='||p_organization_id||' sub='||p_subinventory||' loc='||p_locator_id||' src='||p_source||' vlev='||p_validation_level, G_INFO);
    mdebug('cntitemid='||p_container_item_id||' rev='||p_revision||' lot='||p_lot_number||' fmsn='||p_from_serial_number||' tosn='||p_to_serial_number||' cstgrp='||p_cost_group_id, G_INFO);
    mdebug('prefix='||p_lpn_prefix||' suffix='||p_lpn_suffix||' strtnum='||p_starting_num ||' qty=' ||p_quantity);
    mdebug('scrtype='||p_source_type_id||' srchdr='||p_source_header_id||' srcname=' ||p_source_name||' srcln='||p_source_line_id||' srclndet='||p_source_line_detail_id, G_INFO);
  END IF;

  l_progress := 'Validate all inputs if validation level is set to full';

  IF (p_validation_level = fnd_api.g_valid_level_full) THEN
    l_progress := 'Validate Organization ID';
    l_org.organization_id  := p_organization_id;
    l_result               := inv_validate.ORGANIZATION(l_org);

    IF (l_result = inv_validate.f) THEN
      IF (l_debug = 1) THEN
         mdebug(p_organization_id || ' is not a valid org id', G_ERROR);
      END IF;
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_progress := 'Validate Container Item';
    IF (p_container_item_id IS NOT NULL) THEN
      l_container_item.inventory_item_id  := p_container_item_id;
      l_result                            := inv_validate.inventory_item(l_container_item, l_org);

      IF (l_result = inv_validate.f) THEN
        IF (l_debug = 1) THEN
           mdebug(p_container_item_id || ' is not a valid container item id', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF (l_container_item.container_item_flag = 'N') THEN
        IF (l_debug = 1) THEN
           mdebug(p_container_item_id || ' is not a container', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_ITEM_NOT_A_CONT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    l_progress := 'Validate Subinventory';
    IF (p_subinventory IS NOT NULL) THEN
      l_sub.secondary_inventory_name  := p_subinventory;
      l_result                        := inv_validate.subinventory(l_sub, l_org);

      IF (l_result = inv_validate.f) THEN
        IF (l_debug = 1) THEN
           mdebug(p_subinventory || ' is not a valid sub', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    l_progress := 'Validate Locator';
    IF (p_subinventory IS NOT NULL) THEN
      IF (l_sub.locator_type IN (2, 3)) THEN
        IF (p_locator_id IS NULL) THEN
          IF (l_debug = 1) THEN
             mdebug('Generate_LPN is missing required loc', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOC');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        l_locator.inventory_location_id  := p_locator_id;
        l_result                         := inv_validate.validatelocator(l_locator, l_org, l_sub);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_locator_id || ' is not a valid loc id', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOC');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    l_progress := 'Validate Revision';
    IF (p_container_item_id IS NOT NULL) THEN
      IF (l_container_item.revision_qty_control_code = 2) THEN
        IF (p_revision IS NOT NULL) THEN
          l_result  := inv_validate.revision(p_revision, l_org, l_container_item);

          IF (l_result = inv_validate.f) THEN
            IF (l_debug = 1) THEN
               mdebug(p_revision || ' is not a valid rev', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_REV');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
              --Rev not supported for container items currently.  Allow to use rev controlled items
                                              IF (l_debug = 1) THEN
                                              mdebug('Generate_LPN is missing the rev for rev container item..ok', 1);
                                              END IF;
          --fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_REV');
          --fnd_msg_pub.ADD;
          --RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    l_progress := 'Validate Lot';
    IF (p_container_item_id IS NOT NULL) THEN
      IF (l_container_item.lot_control_code = 2) THEN
        IF (p_lot_number IS NOT NULL) THEN
          l_lot.lot_number  := p_lot_number;
          l_result          := inv_validate.lot_number(l_lot, l_org, l_container_item, l_sub, l_locator, p_revision);

          IF (l_result = inv_validate.f) THEN
            IF (l_debug = 1) THEN
               mdebug(p_lot_number || ' is not a valid lot', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
              --Lots not supported for container items currently.  Allow to use lot controlled items
                                              IF (l_debug = 1) THEN
                                              mdebug('Generate_LPN is missing lot for lot container item..ok', 1);
                                              END IF;
          --fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOT');
          --fnd_msg_pub.ADD;
          --RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    l_progress := 'Validate Serial';
    IF (p_container_item_id IS NOT NULL) THEN
      IF (l_container_item.serial_number_control_code <> 1) THEN
        IF ((p_from_serial_number IS NOT NULL) AND (p_to_serial_number IS NOT NULL)) THEN
          /* Call this API to parse the serial numbers into prefixes and numbers */
          IF (NOT mtl_serial_check.inv_serial_info(p_from_serial_number, p_to_serial_number, l_prefix, l_quantity_serial, l_from_number, l_to_number, l_errorcode)) THEN
            IF (l_debug = 1) THEN
               mdebug(p_to_serial_number || ' failed MTL_Serial_Check', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          -- Check that in the case of a range of serial numbers, that the
          -- inputted p_quantity equals the amount of items in the serial range.
          IF (p_quantity IS NOT NULL) THEN
            IF (p_quantity <> l_quantity_serial) THEN
              IF (l_debug = 1) THEN
                 mdebug(p_quantity || ' does not match sn range qty of ' || l_quantity_serial, 1);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_X_QTY');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;

          -- Get the serial number length.
          -- Note that the from and to serial numbers must be of the same length.
          l_length          := LENGTH(p_from_serial_number);
          -- Initialize the current pointer variables
          l_current_serial  := p_from_serial_number;
          l_current_number  := l_from_number;

          LOOP
            IF (p_subinventory IS NOT NULL) THEN
              l_serial.serial_number  := l_current_serial;
              l_result                := inv_validate.validate_serial(l_serial, l_org, l_container_item, l_sub, l_lot, l_locator, p_revision);

              IF (l_result = inv_validate.f) THEN
                IF (l_debug = 1) THEN
                   mdebug(l_current_serial || 'failed validate_serial', 1);
                END IF;
                fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            ELSE
              -- Subinventory was not given so will need to do
              -- alternative non-standard serial number validation.
              OPEN serial_validation_cursor;
              FETCH serial_validation_cursor INTO l_serial_validate;

              IF serial_validation_cursor%NOTFOUND THEN
                IF (l_debug = 1) THEN
                   mdebug(l_current_serial || ' could not be found in MTL_SERIAL_NUMBERS', 1);
                END IF;
                fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;

              CLOSE serial_validation_cursor;
            END IF;

            EXIT WHEN l_current_serial = p_to_serial_number;
            /* Increment the current serial number */
            l_current_number  := l_current_number + 1;
            l_padded_length   := l_length - LENGTH(l_current_number);
            IF l_prefix IS NOT NULL THEN
               l_current_serial := RPAD(l_prefix, l_padded_length, '0') ||
                 l_current_number;
             ELSE
               l_current_serial := Rpad('@',l_padded_length+1,'0')
                 || l_current_number;
               l_current_serial := Substr(l_current_serial,2);
            END IF;
            -- Bug 2375043
            --l_current_serial := RPAD(l_prefix, l_padded_length, '0') || l_current_number;
          END LOOP;
        ELSE
              --SN not supported for container items currently.  Allow to use serial controlled items
          IF (l_debug = 1) THEN
             mdebug('Generate_LPN is missing sn for serial container item..ok', 1);
          END IF;
          --fnd_message.set_name('WMS', 'WMS_CONT_MISS_SER_NUM');
          --fnd_msg_pub.ADD;
          --RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    l_progress := 'Validate quantity';
    IF (p_quantity IS NOT NULL) THEN
      IF (p_quantity <= 0) THEN
        IF (l_debug = 1) THEN
           mdebug(p_quantity || ' is a negative qty', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_NEG_QTY');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      l_quantity  := p_quantity;
    ELSE
      l_quantity  := 1;
    END IF;

    l_progress := 'Validate the source, i.e. LPN Context';
    IF (p_source IS NOT NULL) THEN
      IF (p_source NOT IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)) THEN
        IF (l_debug = 1) THEN
           mdebug(p_source || ' is an invalid source', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN_CONTEXT');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    l_progress := 'Validate Cost Group';
    IF (p_cost_group_id IS NOT NULL) THEN
      l_result  := inv_validate.cost_group(p_cost_group_id, p_organization_id);

      IF (l_result = inv_validate.f) THEN
        IF (l_debug = 1) THEN
           mdebug(p_cost_group_id || ' is an invalid cost group id', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CST_GRP');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  END IF;

  l_progress := 'End of Input Validation';

  l_lpn_att_rec.lpn_context           := p_source;
  l_lpn_att_rec.organization_id       := p_organization_id;
  l_lpn_att_rec.subinventory_code     := p_subinventory;
  l_lpn_att_rec.locator_id            := p_locator_id;
  l_lpn_att_rec.inventory_item_id     := p_container_item_id;
  l_lpn_att_rec.revision              := p_revision;
  l_lpn_att_rec.lot_number            := p_lot_number;
  l_lpn_att_rec.cost_group_id         := p_cost_group_id;
  l_lpn_att_rec.source_type_id        := p_source_type_id;
  l_lpn_att_rec.source_header_id      := p_source_header_id;
  l_lpn_att_rec.source_name           := p_source_name;
  l_lpn_att_rec.source_line_id        := p_source_line_id;
  l_lpn_att_rec.source_line_detail_id := p_source_line_detail_id;

  l_serial_tbl(1).fm_serial_number := p_from_serial_number;
  l_serial_tbl(1).to_serial_number := p_to_serial_number;

  WMS_Container_PVT.Auto_Create_LPNs (
    p_api_version         => p_api_version
  , p_init_msg_list       => fnd_api.g_false
  , p_commit              => fnd_api.g_false
  , x_return_status       => x_return_status
  , x_msg_count           => x_msg_count
  , x_msg_data            => x_msg_data
  , p_caller              => 'WMS_Generate_LPN'
  , p_quantity            => p_quantity
  , p_lpn_prefix          => p_lpn_prefix
  , p_lpn_suffix          => p_lpn_suffix
  , p_starting_number     => p_starting_num
  , p_total_lpn_length    => p_total_length
  , p_ucc_128_suffix_flag => p_ucc_128_suffix_flag
  , p_lpn_attributes      => l_lpn_att_rec
  , p_serial_ranges       => l_serial_tbl
  , x_created_lpns        => l_gen_lpn_tbl
  , p_client_code         => p_client_code  -- Added for LSP, bug 9087971
  );

  IF ( x_return_status = fnd_api.g_ret_sts_success ) THEN
    p_lpn_id_out := l_gen_lpn_tbl(1).lpn_id;
    p_lpn_out    := l_gen_lpn_tbl(1).license_plate_number;
  ELSE
    IF ( l_debug = 1 ) THEN
      mdebug('Call to WMS_Container_PVT.Auto_Create_LPNs Failed', G_ERROR);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_progress := 'End of API body';

  -- Standard check of p_commit.
  IF fnd_api.to_boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1,
  -- get message info.
  fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' EXC_ERROR progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
      mdebug('msg: '||l_msgdata, G_ERROR);
    END IF;
    ROLLBACK TO GENERATE_LPN_PUB;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), G_ERROR);
    END IF;
    ROLLBACK TO GENERATE_LPN_PUB;
END generate_lpn;

  -- ----------------------------------------------------------------------------------
  -- ----------------------------------------------------------------------------------
  PROCEDURE associate_lpn(
    p_api_version           IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false,
    p_commit                IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN     NUMBER := fnd_api.g_valid_level_full,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_lpn_id                IN     NUMBER,
    p_container_item_id     IN     NUMBER,
    p_lot_number            IN     VARCHAR2 := NULL,
    p_revision              IN     VARCHAR2 := NULL,
    p_serial_number         IN     VARCHAR2 := NULL,
    p_organization_id       IN     NUMBER,
    p_subinventory          IN     VARCHAR2 := NULL,
    p_locator_id            IN     NUMBER := NULL,
    p_cost_group_id         IN     NUMBER := NULL,
    p_source_type_id        IN     NUMBER := NULL,
    p_source_header_id      IN     NUMBER := NULL,
    p_source_name           IN     VARCHAR2 := NULL,
    p_source_line_id        IN     NUMBER := NULL,
    p_source_line_detail_id IN     NUMBER := NULL
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)         := 'Associate_LPN';
    l_api_version CONSTANT NUMBER               := 1.0;
    l_lpn                  lpn;
    l_container_item       inv_validate.item;
    l_org                  inv_validate.org;
    l_sub                  inv_validate.sub;
    l_locator              inv_validate.LOCATOR;
    l_lot                  inv_validate.lot;
    l_serial               inv_validate.serial;
    l_result               NUMBER;
    l_new_lpn_id           NUMBER;
    l_new_lpn              VARCHAR2(30);
    l_insert_update_flag   VARCHAR2(1); -- flag to signal existing lpn or new one
    l_curr_seq             NUMBER;
    l_new_weight           NUMBER;
    l_new_weight_uom       VARCHAR2(3);
    l_net_weight           NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        BEGIN
                -- Standard Start of API savepoint
                SAVEPOINT associate_lpn_pub;

                -- Standard call to check for call compatibility.
                IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
                  fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                -- Initialize message list if p_init_msg_list is set to TRUE.
                IF fnd_api.to_boolean(p_init_msg_list) THEN
                  fnd_msg_pub.initialize;
                END IF;

                -- Initialize API return status to success
                x_return_status  := fnd_api.g_ret_sts_success;

                -- API body
                IF (l_debug = 1) THEN
                mdebug('Call to Associate_LPN API', G_MESSAGE);
                mdebug('orgid=' ||p_organization_id|| ' sub=' ||p_subinventory|| ' loc=' ||p_locator_id|| ' lpnid=' ||p_lpn_id, G_INFO);
                mdebug('itemid=' ||p_container_item_id|| ' rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' sn=' ||p_serial_number, G_INFO);
                mdebug('cg=' ||p_cost_group_id|| ' srctype=' ||p_source_type_id||' srchdr='||p_source_header_id||' srcln='||p_source_line_id, G_INFO);
                END IF;

    /* Validate all inputs if validation level is set to full */
    IF (p_validation_level = fnd_api.g_valid_level_full) THEN
      /* Check that lpn id is given */
      IF (p_lpn_id IS NULL) THEN
        fnd_message.set_name('WMS', 'WMS_CONT_LPN_NOT_GIVEN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate the LPN */
      l_lpn.lpn_id                := p_lpn_id;
      l_lpn.license_plate_number  := NULL;
      l_result                    := validate_lpn(l_lpn);

      IF (l_result = inv_validate.f) THEN
        l_new_lpn_id          := p_lpn_id;
        l_insert_update_flag  := 'i';
      ELSE
        l_insert_update_flag  := 'u';
      END IF;

      /* Validate Organization ID */
      l_org.organization_id       := p_organization_id;
      l_result                    := inv_validate.ORGANIZATION(l_org);

      IF (l_result = inv_validate.f) THEN
        IF (l_debug = 1) THEN
           mdebug(p_organization_id || ' is an invalid org id', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Subinventory */
      IF (p_subinventory IS NOT NULL) THEN
        l_sub.secondary_inventory_name  := p_subinventory;
        l_result                        := inv_validate.subinventory(l_sub, l_org);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_subinventory || ' is an invalid sub', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Locator */
      IF (p_subinventory IS NOT NULL) THEN
        IF (l_sub.locator_type IN (2, 3)) THEN
          IF (p_locator_id IS NULL) THEN
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOC');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          l_locator.inventory_location_id  := p_locator_id;
          l_result                         := inv_validate.validatelocator(l_locator, l_org, l_sub);

          IF (l_result = inv_validate.f) THEN
            IF (l_debug = 1) THEN
               mdebug(p_locator_id || ' is an invalid loc id', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOC');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Container Item */
          /* Validate Container Item */
      IF (p_container_item_id IS NOT NULL) THEN
        l_container_item.inventory_item_id  := p_container_item_id;
        l_result                            := inv_validate.inventory_item(l_container_item, l_org);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_container_item_id || ' is an invalid container item id', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_container_item.container_item_flag = 'N') THEN
          IF (l_debug = 1) THEN
             mdebug(p_container_item_id || ' is not a container item', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_ITEM_NOT_A_CONT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_container_item.unit_weight IS NOT NULL) THEN
          IF (l_lpn.gross_weight IS NOT NULL) THEN
            -- convert container item weight to lpn gross weight uom
            l_new_weight      :=
                             inv_convert.inv_um_convert(l_container_item.inventory_item_id, 5, l_container_item.unit_weight, l_container_item.weight_uom_code, l_lpn.gross_weight_uom_code, NULL, NULL);
            -- add lpn gross weight into new gross weight.
            l_new_weight      := l_new_weight + l_lpn.gross_weight;
            l_new_weight_uom  := l_lpn.gross_weight_uom_code;
          ELSE
            --lpn has no weight, use container item weights
            l_new_weight      := l_container_item.unit_weight;
            l_new_weight_uom  := l_container_item.weight_uom_code;
          END IF;
        ELSE
          --weight not specified for container item, use default lpn weights
          l_new_weight      := l_lpn.gross_weight;
          l_new_weight_uom  := l_lpn.gross_weight_uom_code;
        END IF;
      ELSE
        fnd_message.set_name('WMS', 'WMS_CONT_CONTAINER_NOT_GIVEN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

                /* Validate Revision */
                IF (p_container_item_id IS NOT NULL) THEN
                  IF (l_container_item.revision_qty_control_code = 2) THEN
                    IF (p_revision IS NOT NULL) THEN
                      l_result  := inv_validate.revision(p_revision, l_org, l_container_item);

                      IF (l_result = inv_validate.f) THEN
                        IF (l_debug = 1) THEN
                        mdebug(p_revision || ' is an invalid rev', 1);
                        END IF;
                        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_REV');
                        fnd_msg_pub.ADD;
                        RAISE fnd_api.g_exc_error;
                      END IF;
                    ELSE
                        --Rev not supported for container items currently.  Allow to use rev controlled items
                                        IF (l_debug = 1) THEN
                                        mdebug('Associate_LPN is missing the rev for rev container item..ok', 1);
                                        END IF;
                      --fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_REV');
                      --fnd_msg_pub.ADD;
                      --RAISE fnd_api.g_exc_error;
                    END IF;
                  END IF;
                END IF;

                /* Validate Lot */
                IF (p_container_item_id IS NOT NULL) THEN
                        IF (l_container_item.lot_control_code = 2) THEN
                                IF (p_lot_number IS NOT NULL) THEN
                                        l_lot.lot_number  := p_lot_number;
                                        l_result          := inv_validate.lot_number(l_lot, l_org, l_container_item, l_sub, l_locator, p_revision);

                                        IF (l_result = inv_validate.f) THEN
                                          IF (l_debug = 1) THEN
                                          mdebug(p_lot_number || ' is not a valid lot', 1);
                                          END IF;
                                          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOT');
                                          fnd_msg_pub.ADD;
                                          RAISE fnd_api.g_exc_error;
                                        END IF;
                                ELSE
                                        --Lots not supported for container items currently.  Allow to use lot controlled items
                                        IF (l_debug = 1) THEN
                                        mdebug('Associate_LPN is missing lot for lot container item..ok', 1);
                                        END IF;
                                        --fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOT');
                                        --fnd_msg_pub.ADD;
                                        --RAISE fnd_api.g_exc_error;
                                END IF;
                        END IF;
                END IF;

                /* Validate Serial */
                IF (p_container_item_id IS NOT NULL) THEN
                  IF (l_container_item.serial_number_control_code <> 1) THEN
                    IF (p_serial_number IS NOT NULL) THEN
                      l_serial.serial_number  := p_serial_number;
                      l_result                := inv_validate.validate_serial(l_serial, l_org, l_container_item, l_sub, l_lot, l_locator, p_revision);

                      IF (l_result = inv_validate.f) THEN
                        IF (l_debug = 1) THEN
                        mdebug(p_serial_number || ' is an invalid sn', 1);
                        END IF;
                        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
                        fnd_msg_pub.ADD;
                        RAISE fnd_api.g_exc_error;
                      END IF;
                    ELSE
                                        --SN not supported for container items currently.  Allow to use serial controlled items
                                        IF (l_debug = 1) THEN
                                        mdebug('Associate_LPN is missing sn for serial container item..ok', 1);
                                        END IF;
                                        --fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_SER');
                                        --fnd_msg_pub.ADD;
                                        --RAISE fnd_api.g_exc_error;
                    END IF;
                  END IF;
                END IF;

                /* Validate Cost Group */
                IF (p_cost_group_id IS NOT NULL) THEN
                  l_result  := inv_validate.cost_group(p_cost_group_id, p_organization_id);

                  IF (l_result = inv_validate.f) THEN
                    IF (l_debug = 1) THEN
                    mdebug(p_cost_group_id || ' is an invalid cg', 1);
                    END IF;
                    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CST_GRP');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_error;
                  END IF;
                END IF;
        END IF;

    /* End of input validation */

    -- Necessary validation to get local values
    -- if full validation was not performed
    IF (p_validation_level <> fnd_api.g_valid_level_full) THEN
      /* Validate the LPN */
      l_lpn.lpn_id                := p_lpn_id;
      l_lpn.license_plate_number  := NULL;
      l_result                    := validate_lpn(l_lpn);

      IF (l_result = inv_validate.f) THEN
        l_new_lpn_id          := p_lpn_id;
        l_insert_update_flag  := 'i';
      ELSE
        l_insert_update_flag  := 'u';
      END IF;

      /* Validate Organization ID */
      l_org.organization_id       := p_organization_id;
      l_result                    := inv_validate.ORGANIZATION(l_org);

      IF (l_result = inv_validate.f) THEN
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Container Item */
      IF (p_container_item_id IS NOT NULL) THEN
        l_container_item.inventory_item_id  := p_container_item_id;
        l_result                            := inv_validate.inventory_item(l_container_item, l_org);

        IF (l_result = inv_validate.f) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_container_item.container_item_flag = 'N') THEN
          fnd_message.set_name('WMS', 'WMS_CONT_ITEM_NOT_A_CONT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_container_item.unit_weight IS NOT NULL) THEN
          IF (l_lpn.gross_weight IS NOT NULL) THEN
            -- convert container item weight to lpn gross weight uom
            l_new_weight      :=
                             inv_convert.inv_um_convert(l_container_item.inventory_item_id, 5, l_container_item.unit_weight, l_container_item.weight_uom_code, l_lpn.gross_weight_uom_code, NULL, NULL);
            -- add lpn gross weight into new gross weight.
            l_new_weight      := l_new_weight + l_lpn.gross_weight;
            l_new_weight_uom  := l_lpn.gross_weight_uom_code;
          ELSE
            --lpn has no weight, use container item weights
            l_new_weight      := l_container_item.unit_weight;
            l_new_weight_uom  := l_container_item.weight_uom_code;
          END IF;
        ELSE
          --weight not specified for container item, use default lpn weights
          l_new_weight      := l_lpn.gross_weight;
          l_new_weight_uom  := l_lpn.gross_weight_uom_code;
        END IF;
      ELSE
        fnd_message.set_name('WMS', 'WMS_CONT_CONTAINER_NOT_GIVEN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF (l_insert_update_flag = 'u') THEN
      UPDATE wms_license_plate_numbers
         SET inventory_item_id = p_container_item_id,
             last_update_date = SYSDATE,
             last_updated_by = fnd_global.user_id,
             revision = p_revision,
             lot_number = p_lot_number,
             serial_number = p_serial_number,
             organization_id = p_organization_id,
             subinventory_code = p_subinventory,
             /* Bug 3936269 Modifying the locator_id field as null if p_locator_id =0
             locator_id = p_locator_id, */
             locator_id = decode (p_locator_id,0,null,p_locator_id),
             --End of fix for Bug 3936269
             gross_weight_uom_code = l_new_weight_uom,
             gross_weight = l_new_weight,
             tare_weight_uom_code = l_container_item.weight_uom_code,
             tare_weight = l_container_item.unit_weight,
             sealed_status = 2,
             cost_group_id = p_cost_group_id,
             source_type_id = p_source_type_id,
             source_header_id = p_source_header_id,
             source_line_id = p_source_line_id,
             source_line_detail_id = p_source_line_detail_id,
             source_name = p_source_name
       WHERE lpn_id = p_lpn_id;

      /* Added code to check if the LPN being updated is in Shipping
         if so, then the updated Wt ,container item are passed on to the
         WSH_DELIVERY_DETAILS table. Bug#2200989*/

      l_net_weight  := l_lpn.gross_weight;
      IF (l_debug = 1) THEN
         mdebug('Associate LPN***before update of shipping details***');
         mdebug('Associate LPN***old gross weight='|| l_lpn.gross_weight);
         mdebug('Associate LPN***new gross weight='|| l_new_weight);
         mdebug('Associate LPN***net weight='|| l_net_weight);
      END IF;

     --Bug #3370346 (Passing the correct values for Gross Wt and Net Wt Parameters)
     update_shipping_details(
                                p_lpn_id         =>  p_lpn_id
                              , p_gross_weight   =>  l_new_weight
                              , p_net_weight     =>  l_net_weight
                              , p_weight_uom     =>  l_new_weight_uom
                              , p_volume         =>  l_lpn.content_volume
                              , p_volume_uom     =>  l_lpn.content_volume_uom_code
                            );
/* End bug#2200989 */


    ELSE  /* l_insert_update_flag = 'i' */
      /* Need to generate a license plate number to go along with the given lpn id */
      LOOP
        SELECT wms_license_plate_numbers_s2.NEXTVAL
          INTO l_curr_seq
          FROM DUAL;

        l_new_lpn                   := l_org.lpn_prefix || TO_CHAR(l_curr_seq) || l_org.lpn_suffix;
        l_lpn.lpn_id                := l_new_lpn_id;
        l_lpn.license_plate_number  := l_new_lpn;
        l_result                    := validate_lpn(l_lpn);

        IF (l_result = inv_validate.f) THEN
          EXIT;
        END IF;
      END LOOP;

      INSERT INTO wms_license_plate_numbers
                  (
                  lpn_id,
                  license_plate_number,
                  inventory_item_id,
                  last_update_date,
                  last_updated_by,
                  creation_date,
                  created_by,
                  revision,
                  lot_number,
                  serial_number,
                  organization_id,
                  subinventory_code,
                  locator_id,
                  parent_lpn_id,
                  gross_weight_uom_code,
                  gross_weight,
                  content_volume_uom_code,
                  content_volume,
                  tare_weight_uom_code,
                  tare_weight,
                  status_id,
                  lpn_context,
                  sealed_status,
                  cost_group_id,
                  source_type_id,
                  source_header_id,
                  source_line_id,
                  source_line_detail_id,
                  source_name
                  )
           VALUES (
                  l_new_lpn_id,
                  l_new_lpn,
                  p_container_item_id,
                  SYSDATE,
                  fnd_global.user_id,
                  SYSDATE,
                  fnd_global.user_id,
                  p_revision,
                  p_lot_number,
                  p_serial_number,
                  p_organization_id,
                  p_subinventory,
                  /* Bug 3936269 Inserting null for the locator_id field if p_locator_id is 0
                  p_locator_id,*/
                  decode(p_locator_id,0,null,p_locator_id),
                  --End of fix for Bug 3936269
                  NULL,
                  l_container_item.weight_uom_code,
                  l_container_item.unit_weight,
                  l_container_item.volume_uom_code,
                  0,
                  l_container_item.weight_uom_code,
                  l_container_item.unit_weight,
                  NULL,
                  1,
                  2,
                  p_cost_group_id,
                  p_source_type_id,
                  p_source_header_id,
                  p_source_line_id,
                  p_source_line_detail_id,
                  p_source_name
                  );
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO associate_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO associate_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO associate_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END associate_lpn;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Create_LPN (
  p_api_version            IN         NUMBER
, p_init_msg_list          IN         VARCHAR2 := fnd_api.g_false
, p_commit                 IN         VARCHAR2 := fnd_api.g_false
, p_validation_level       IN         NUMBER   := fnd_api.g_valid_level_full
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
, p_lpn                    IN         VARCHAR2
, p_organization_id        IN         NUMBER
, p_container_item_id      IN         NUMBER   := NULL
, p_lot_number             IN         VARCHAR2 := NULL
, p_revision               IN         VARCHAR2 := NULL
, p_serial_number          IN         VARCHAR2 := NULL
, p_subinventory           IN         VARCHAR2 := NULL
, p_locator_id             IN         NUMBER   := NULL
, p_source                 IN         NUMBER   := LPN_CONTEXT_PREGENERATED
, p_cost_group_id          IN         NUMBER   := NULL
, p_parent_lpn_id          IN         NUMBER   := NULL
, p_source_type_id         IN         NUMBER   := NULL
, p_source_header_id       IN         NUMBER   := NULL
, p_source_name            IN         VARCHAR2 := NULL
, p_source_line_id         IN         NUMBER   := NULL
, p_source_line_detail_id  IN         NUMBER   := NULL
, x_lpn_id                 OUT NOCOPY NUMBER
) IS
    l_api_name    CONSTANT VARCHAR2(30)                             := 'Create_LPN';
    l_api_version CONSTANT NUMBER                                   := 1.0;
    l_lpn                  lpn;
    l_parent_lpn           lpn;
    l_container_item       inv_validate.item;
    l_org                  inv_validate.org;
    l_sub                  inv_validate.sub;
    l_locator              inv_validate.LOCATOR;
    l_lot                  inv_validate.lot;
    l_serial               inv_validate.serial;
    l_result               NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT create_lpn_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status               := fnd_api.g_ret_sts_success;
    -- API body
   IF (l_debug = 1) THEN
      mdebug('Call to Create_LPN orgid=' ||p_organization_id|| ' sub=' ||p_subinventory|| ' loc=' ||p_locator_id|| ' lpn=' ||p_lpn|| ' src=' ||p_source, G_INFO);
        mdebug('cntitemid=' ||p_container_item_id|| ' rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' sn=' ||p_serial_number|| ' cstgrp=' ||p_cost_group_id, G_INFO);
        mdebug('prntlpnid=' ||p_parent_lpn_id|| ' scrtype=' ||p_source_type_id|| ' srchdr=' ||p_source_header_id|| ' srcname=' ||p_source_name|| ' srcln=' ||p_source_line_id||' srclndet='||p_source_line_detail_id, G_INFO);
   END IF;

    /* Validate all inputs if validation level is set to full */
    IF (p_validation_level = fnd_api.g_valid_level_full) THEN
      /* Validate LPN */
      l_lpn.license_plate_number  := p_lpn;
      l_lpn.lpn_id                := NULL;
      l_result                    := validate_lpn(l_lpn);

      IF (l_result = inv_validate.t) THEN
        IF (l_debug = 1) THEN
           mdebug(p_lpn || ' failed LPN validation', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_DUPLICATE_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Parent LPN */
      IF (p_parent_lpn_id IS NOT NULL) THEN
        l_parent_lpn.lpn_id                := p_parent_lpn_id;
        l_parent_lpn.license_plate_number  := NULL;
        l_result                           := validate_lpn(l_parent_lpn);

        IF (l_result = inv_validate.t) THEN
          IF (l_debug = 1) THEN
             mdebug(p_parent_lpn_id || ' parent LPN failed validation', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Organization ID */
      l_org.organization_id       := p_organization_id;
      l_result                    := inv_validate.ORGANIZATION(l_org);

      IF (l_result = inv_validate.f) THEN
        IF (l_debug = 1) THEN
           mdebug(p_organization_id || ' is an invalid Org', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Subinventory */
      IF (p_subinventory IS NOT NULL) THEN
        l_sub.secondary_inventory_name  := p_subinventory;
        l_result                        := inv_validate.subinventory(l_sub, l_org);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_subinventory || ' Invalid Subinventory', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Locator */
      IF (p_subinventory IS NOT NULL) THEN
        IF (l_sub.locator_type IN (2, 3)) THEN
          IF (p_locator_id IS NULL) THEN
            IF (l_debug = 1) THEN
               mdebug('Missing required locator', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOC');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          l_locator.inventory_location_id  := p_locator_id;
          l_result                         := inv_validate.validatelocator(l_locator, l_org, l_sub);

          IF (l_result = inv_validate.f) THEN
            IF (l_debug = 1) THEN
               mdebug(p_locator_id || ' is an invalid locator', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOC');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Container Item */
      IF (p_container_item_id IS NOT NULL) THEN
        l_container_item.inventory_item_id  := p_container_item_id;
        l_result                            := inv_validate.inventory_item(l_container_item, l_org);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_container_item_id || ' is an invalid container item', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_container_item.container_item_flag = 'N') THEN
          IF (l_debug = 1) THEN
             mdebug(p_container_item_id || ' is not a container', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_ITEM_NOT_A_CONTAINER');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Revision */
      IF (p_container_item_id IS NOT NULL) THEN
        IF (l_container_item.revision_qty_control_code = 2) THEN
          IF (p_revision IS NOT NULL) THEN
            l_result  := inv_validate.revision(p_revision, l_org, l_container_item);

            IF (l_result = inv_validate.f) THEN
              IF (l_debug = 1) THEN
                 mdebug(p_revision || ' is an invalid Revision', 1);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_REV');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
                --Revision not supported for container items currently.  Allow to use rev controlled items
                                                IF (l_debug = 1) THEN
                                                mdebug('Generate_LPN is missing rev for lot container item..ok', 1);
                                                END IF;
            --fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_REV');
            --fnd_msg_pub.ADD;
            --RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Lot */
      IF (p_container_item_id IS NOT NULL) THEN
        IF (l_container_item.lot_control_code = 2) THEN
          IF (p_lot_number IS NOT NULL) THEN
            l_lot.lot_number  := p_lot_number;
            l_result          := inv_validate.lot_number(l_lot, l_org, l_container_item, l_sub, l_locator, p_revision);

            IF (l_result = inv_validate.f) THEN
              IF (l_debug = 1) THEN
                 mdebug(p_lot_number || ' is an invalid lot', 1);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOT');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
                --Lots not supported for container items currently.  Allow to use lot controlled items
                                                IF (l_debug = 1) THEN
                                                mdebug('Generate_LPN is missing lot for lot container item..ok', 1);
                                                END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Serial */
      IF (p_container_item_id IS NOT NULL) THEN
        IF (l_container_item.serial_number_control_code <> 1) THEN
          IF (p_serial_number IS NOT NULL) THEN
            l_serial.serial_number  := p_serial_number;
            l_result                := inv_validate.validate_serial(l_serial, l_org, l_container_item, l_sub, l_lot, l_locator, p_revision);

            IF (l_result = inv_validate.f) THEN
              IF (l_debug = 1) THEN
                 mdebug(l_serial.serial_number || ' is an invalid Serial Number', 1);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
                --SN not supported for container items currently.  Allow to use serial controlled items
                                                IF (l_debug = 1) THEN
                                                mdebug('Create_LPN is missing sn for serial container item..ok', 1);
                                                END IF;
            --fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_SER');
            --fnd_msg_pub.ADD;
            --RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Source, i.e. LPN Context */
      IF (p_source IS NOT NULL) THEN
        IF (p_source NOT IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)) THEN
          IF (l_debug = 1) THEN
             mdebug(p_source || 'is an invalid source type', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN_CONTEXT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Cost Group */
      IF (p_cost_group_id IS NOT NULL) THEN
        l_result  := inv_validate.cost_group(p_cost_group_id, p_organization_id);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_cost_group_id || 'is an invalid cost group', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CST_GRP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

    /* End of input validation */

    WMS_CONTAINER_PVT.Create_LPN (
      p_api_version           => p_api_version
    , p_init_msg_list         => p_init_msg_list
    , p_commit                => p_commit
    , p_validation_level      => p_validation_level
    , x_return_status         => x_return_status
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    , p_lpn                   => p_lpn
    , p_organization_id       => p_organization_id
    , p_container_item_id     => p_container_item_id
    , p_lot_number            => p_lot_number
    , p_revision              => p_revision
    , p_serial_number         => p_serial_number
    , p_subinventory          => p_subinventory
    , p_locator_id            => p_locator_id
    , p_source                => p_source
    , p_cost_group_id         => p_cost_group_id
    , p_parent_lpn_id         => p_parent_lpn_id
    , p_source_type_id        => p_source_type_id
    , p_source_header_id      => p_source_header_id
    , p_source_name           => p_source_name
    , p_source_line_id        => p_source_line_id
    , p_source_line_detail_id => p_source_line_detail_id
    , x_lpn_id                => x_lpn_id );

    IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
      IF ( l_debug = 1 ) THEN
        mdebug('Call to WMS_CONTAINER_PVT.Create_LPN Failed', G_ERROR);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END create_lpn;

  -- ----------------------------------------------------------------------------------
  -- ----------------------------------------------------------------------------------
  PROCEDURE modify_lpn(
    p_api_version           IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false,
    p_commit                IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN     NUMBER := fnd_api.g_valid_level_full,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_lpn                   IN     lpn,
    p_source_type_id        IN     NUMBER := NULL,
    p_source_header_id      IN     NUMBER := NULL,
    p_source_name           IN     VARCHAR2 := NULL,
    p_source_line_id        IN     NUMBER := NULL,
    p_source_line_detail_id IN     NUMBER := NULL
  ) IS
    l_api_name     CONSTANT VARCHAR2(30)                        := 'Modify_LPN';
    l_api_version  CONSTANT NUMBER                              := 1.0;
    l_lpn                   lpn;
    l_container_item        inv_validate.item;
    l_parent_item           inv_validate.item;
    l_org                   inv_validate.org;
    l_sub                   inv_validate.sub;
    l_locator               inv_validate.LOCATOR;
    l_result                NUMBER;
    l_change_in_weight      NUMBER                              := 0;
    l_change_in_weight_uom  VARCHAR2(3);
    l_location_changed      NUMBER                              := 1;
    l_container_sealed      NUMBER                              := 1;
    l_context_changed       NUMBER                              := 1;
    l_temp_conversion_num   NUMBER;
    l_temp_conversion_num2  NUMBER;
    l_current_lpn           NUMBER;
    l_dummy                 NUMBER;
    l_old_subinventory_code VARCHAR2(30);
    l_old_locator_id        NUMBER;
    l_is_sub_lpn_controlled  BOOLEAN;  -- Bug 2308339

    CURSOR nested_children_lpn_cursor IS
      -- Bug# 1546081
      --  SELECT *
      SELECT     lpn_id,
                 organization_id,
                 subinventory_code,
                 locator_id
            FROM wms_license_plate_numbers
      START WITH lpn_id = p_lpn.lpn_id
      CONNECT BY parent_lpn_id = PRIOR lpn_id;

    CURSOR nested_parent_lpn_cursor IS
      SELECT     *
            FROM wms_license_plate_numbers
      START WITH lpn_id = p_lpn.lpn_id
      CONNECT BY lpn_id = PRIOR parent_lpn_id;

    CURSOR lpn_contents_cursor IS
      -- Bug# 1546081
      --  SELECT *
      SELECT organization_id,
             lpn_content_id,
             parent_lpn_id,
             inventory_item_id
        FROM wms_lpn_contents
       WHERE parent_lpn_id = l_current_lpn;
       --  AND NVL(serial_summary_entry, 2) = 2;

    CURSOR lpn_serial_contents_cursor IS
      -- Bug# 1546081
      --  SELECT *
      SELECT 1
        FROM mtl_serial_numbers
       WHERE lpn_id = l_current_lpn;

    CURSOR lpn_cursor IS
      -- Bug# 1546081
      --  SELECT *
      SELECT 1
        FROM wms_license_plate_numbers
       WHERE parent_lpn_id = l_current_lpn;

    l_lpn_rec               wms_license_plate_numbers%ROWTYPE;
    --l_lpn_contents_rec       WMS_LPN_CONTENTS%ROWTYPE;
    l_lpn_contents_rec      lpn_contents_cursor%ROWTYPE;
    l_lpn_serial_rec        mtl_serial_numbers%ROWTYPE;
    l_net_weight            NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_lpn_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status   := fnd_api.g_ret_sts_success;

    -- API body
    /* Validate all inputs if validation level is set to full */
    IF (p_validation_level = fnd_api.g_valid_level_full) THEN
      /* Validate LPN */
      l_lpn.lpn_id                := p_lpn.lpn_id;
      l_lpn.license_plate_number  := NULL;
      l_result                    := validate_lpn(l_lpn);

      IF (l_result = inv_validate.f) THEN
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Organization */
      IF (p_lpn.organization_id IS NOT NULL) THEN
        l_org.organization_id  := p_lpn.organization_id;
        l_result               := inv_validate.ORGANIZATION(l_org);

        IF (l_result = inv_validate.f) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Subinventory */
      IF (p_lpn.subinventory_code IS NOT NULL) THEN
        l_sub.secondary_inventory_name  := p_lpn.subinventory_code;
        l_result                        := inv_validate.subinventory(l_sub, l_org);

        IF (l_result = inv_validate.f) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Locator */
      IF (p_lpn.subinventory_code IS NOT NULL) THEN
        IF (l_sub.locator_type IN (2, 3)) THEN
          IF (p_lpn.locator_id IS NULL) THEN
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOC');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;

          l_locator.inventory_location_id  := p_lpn.locator_id;
          l_result                         := inv_validate.validatelocator(l_locator, l_org, l_sub);

          IF (l_result = inv_validate.f) THEN
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOC');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Container Item */
      IF (p_lpn.inventory_item_id IS NOT NULL) THEN
        l_container_item.inventory_item_id  := p_lpn.inventory_item_id;
        l_result                            := inv_validate.inventory_item(l_container_item, l_org);

        IF (l_result = inv_validate.f) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        IF (l_container_item.container_item_flag = 'N') THEN
          fnd_message.set_name('WMS', 'WMS_CONT_ITEM_NOT_A_CONTAINER');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Gross Weight */
      IF (p_lpn.gross_weight IS NOT NULL) THEN
        IF (p_lpn.gross_weight < 0) THEN
          IF (l_debug = 1) THEN
             mdebug('gross weight= '|| p_lpn.gross_weight, 9);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_NEG_WEIGHT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Content Volume */
      IF (p_lpn.content_volume IS NOT NULL) THEN
        IF (p_lpn.content_volume < 0) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_NEG_VOLUME');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate LPN Status ID */
      IF (p_lpn.status_id IS NOT NULL) THEN
        IF (p_lpn.status_id NOT IN (1, 2, 3, 4, 5, 6)) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_STATUS_ID');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate LPN Context */
      IF (p_lpn.lpn_context IS NOT NULL) THEN
        IF (p_lpn.lpn_context NOT IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN_CONTEXT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Sealed Status */
      IF (p_lpn.sealed_status IS NOT NULL) THEN
        IF (p_lpn.sealed_status NOT IN (1, 2)) THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SEALED_STAT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;
    /* End of input validation */
    l_lpn := p_lpn;

    IF ( p_source_type_id IS NOT NULL ) THEN
      l_lpn.source_type_id := p_source_type_id;
    ELSIF ( p_lpn.source_type_id IS NULL ) THEN
      l_lpn.source_type_id := fnd_api.g_miss_num;
    END IF;

    IF ( p_source_header_id IS NOT NULL ) THEN
      l_lpn.source_header_id := p_source_header_id;
    ELSIF ( p_lpn.source_header_id IS NULL ) THEN
      l_lpn.source_header_id := fnd_api.g_miss_num;
    END IF;

    IF ( p_source_line_id IS NOT NULL ) THEN
      l_lpn.source_line_id := p_source_line_id;
    ELSIF ( p_lpn.source_line_id IS NULL ) THEN
      l_lpn.source_line_id := fnd_api.g_miss_num;
    END IF;

    IF ( p_source_line_detail_id IS NOT NULL ) THEN
      l_lpn.source_line_detail_id := p_source_line_detail_id;
    ELSIF ( p_lpn.source_line_detail_id IS NULL ) THEN
      l_lpn.source_line_detail_id := fnd_api.g_miss_num;
    END IF;

    IF ( p_source_name IS NOT NULL ) THEN
      l_lpn.source_name := p_source_name;
    ELSIF ( p_lpn.source_name IS NULL ) THEN
      l_lpn.source_name := fnd_api.g_miss_char;
    END IF;

    WMS_CONTAINER_PVT.Modify_LPN (
      p_api_version           => p_api_version
    , p_init_msg_list         => p_init_msg_list
    , p_commit                => p_commit
    , p_validation_level      => p_validation_level
    , x_return_status         => x_return_status
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    , p_lpn                   => l_lpn );

    IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
      IF ( l_debug = 1 ) THEN
        mdebug('Call to WMS_CONTAINER_PVT.Modify_LPN Failed', G_ERROR);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO modify_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO modify_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO modify_lpn_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END modify_lpn;

  PROCEDURE modify_lpn_wrapper(
    p_api_version           IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 := fnd_api.g_false,
    p_commit                IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level      IN     NUMBER := fnd_api.g_valid_level_full,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2,
    p_lpn_id                IN     NUMBER,
    p_license_plate_number  IN     VARCHAR2 := NULL,
    p_inventory_item_id     IN     NUMBER := NULL,
    p_weight_uom_code       IN     VARCHAR2 := NULL,
    p_gross_weight          IN     NUMBER := NULL,
    p_volume_uom_code       IN     VARCHAR2 := NULL,
    p_content_volume        IN     NUMBER := NULL,
    p_status_id             IN     NUMBER := NULL,
    p_lpn_context           IN     NUMBER := NULL,
    p_sealed_status         IN     NUMBER := NULL,
    p_organization_id       IN     NUMBER := NULL,
    p_subinventory          IN     VARCHAR := NULL,
    p_locator_id            IN     NUMBER := NULL,
    p_source_type_id        IN     NUMBER := NULL,
    p_source_header_id      IN     NUMBER := NULL,
    p_source_name           IN     VARCHAR2 := NULL,
    p_source_line_id        IN     NUMBER := NULL,
    p_source_line_detail_id IN     NUMBER := NULL
  ) IS
    l_api_name    CONSTANT VARCHAR2(30) := 'Modify_LPN_Wrapper';
    l_api_version CONSTANT NUMBER       := 1.0;
    l_lpn                  lpn;
    l_result               NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT modify_lpn_wrapper_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status             := fnd_api.g_ret_sts_success;
    -- API body

    /* Validate LPN */
    l_lpn.lpn_id                := p_lpn_id;
    l_lpn.license_plate_number  := NULL;
    l_result                    := validate_lpn(l_lpn);

    IF (l_result = inv_validate.f) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;

    WMS_CONTAINER_PVT.Modify_LPN_Wrapper(
      p_api_version           => p_api_version
    , p_init_msg_list         => p_init_msg_list
    , p_commit                => p_commit
    , p_validation_level      => p_validation_level
    , x_return_status         => x_return_status
    , x_msg_count             => x_msg_count
    , x_msg_data              => x_msg_data
    , p_lpn_id                => p_lpn_id
    , p_license_plate_number  => p_license_plate_number
    , p_inventory_item_id     => p_inventory_item_id
    , p_weight_uom_code       => p_weight_uom_code
    , p_gross_weight          => p_gross_weight
    , p_volume_uom_code       => p_volume_uom_code
    , p_content_volume        => p_content_volume
    , p_status_id             => p_status_id
    , p_lpn_context           => p_lpn_context
    , p_sealed_status         => p_sealed_status
    , p_organization_id       => p_organization_id
    , p_subinventory          => p_subinventory
    , p_locator_id            => p_locator_id
    , p_source_type_id        => p_source_type_id
    , p_source_header_id      => p_source_header_id
    , p_source_name           => p_source_name
    , p_source_line_id        => p_source_line_id
    , p_source_line_detail_id => p_source_line_detail_id );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      -- Modify LPN should put the appropriate error message in the stack
      RAISE fnd_api.g_exc_error;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO modify_lpn_wrapper_pub;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO modify_lpn_wrapper_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO modify_lpn_wrapper_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END modify_lpn_wrapper;

  -- ----------------------------------------------------------------------------------
  -- ----------------------------------------------------------------------------------
  PROCEDURE PackUnpack_Container (
    p_api_version              IN         NUMBER
  , p_init_msg_list            IN         VARCHAR2 := fnd_api.g_false
  , p_commit                   IN         VARCHAR2 := fnd_api.g_false
  , p_validation_level         IN         NUMBER   := fnd_api.g_valid_level_full
  , x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
  , p_lpn_id                   IN         NUMBER
  , p_content_lpn_id           IN         NUMBER   := NULL
  , p_content_item_id          IN         NUMBER   := NULL
  , p_content_item_desc        IN         VARCHAR2 := NULL
  , p_revision                 IN         VARCHAR2 := NULL
  , p_lot_number               IN         VARCHAR2 := NULL
  , p_from_serial_number       IN         VARCHAR2 := NULL
  , p_to_serial_number         IN         VARCHAR2 := NULL
  , p_quantity                 IN         NUMBER   := 1
  , p_uom                      IN         VARCHAR2 := NULL
  , p_sec_quantity             IN         NUMBER   := NULL --INVCONV kkillams
  , p_sec_uom                  IN         VARCHAR2 := NULL --INVCONV kkillams
  , p_organization_id          IN         NUMBER
  , p_subinventory             IN         VARCHAR2 := NULL
  , p_locator_id               IN         NUMBER   := NULL
  , p_enforce_wv_constraints   IN         NUMBER   := 2
  , p_operation                IN         NUMBER
  , p_cost_group_id            IN         NUMBER   := NULL
  , p_source_type_id           IN         NUMBER   := NULL
  , p_source_header_id         IN         NUMBER   := NULL
  , p_source_name              IN         VARCHAR2 := NULL
  , p_source_line_id           IN         NUMBER   := NULL
  , p_source_line_detail_id    IN         NUMBER   := NULL
  , p_homogeneous_container    IN         NUMBER   := 2
  , p_match_locations          IN         NUMBER   := 2
  , p_match_lpn_context        IN         NUMBER   := 2
  , p_match_lot                IN         NUMBER   := 2
  , p_match_cost_groups        IN         NUMBER   := 2
  , p_match_mtl_status         IN         NUMBER   := 2
  , p_unpack_all               IN         NUMBER   := 2
  , p_trx_action_id            IN         NUMBER   := NULL
  , p_concurrent_pack          IN         NUMBER   := 0
  , p_ignore_item_controls     IN         NUMBER   := 2
  ) IS
    l_api_name      CONSTANT VARCHAR2(30)                            := 'PackUnpack_Container';
    l_api_version   CONSTANT NUMBER                                  := 1.0;
    l_lpn                    lpn;
    l_content_lpn            lpn;
    l_content_item           inv_validate.item;
    l_org                    inv_validate.org;
    l_sub                    inv_validate.sub;
    l_locator                inv_validate.LOCATOR;
    l_lot                    inv_validate.lot;
    l_serial                 inv_validate.serial;
    l_current_serial         VARCHAR2(30)                            := p_from_serial_number;
    l_result                 NUMBER;
    l_serial_summary_entry   NUMBER                                  := 2;
    l_unit_weight            NUMBER;
    l_weight_uom_code        VARCHAR2(3);
    l_volume_uom_code        VARCHAR2(3);
    l_unit_volume            NUMBER;
    l_is_sub_lpn_controlled  BOOLEAN;  -- Bug 2308339
    l_row_id                 ROWID;
    l_operation              NUMBER := p_operation;
    l_ignore_item_controls   NUMBER := p_ignore_item_controls;

    CURSOR nested_children_cursor IS
      -- Bug# 1546081
      --  SELECT *
      SELECT     lpn_id
            FROM wms_license_plate_numbers
      START WITH lpn_id = p_content_lpn_id
      CONNECT BY parent_lpn_id = PRIOR lpn_id;

    l_current_lpn            NUMBER;

    CURSOR lpn_contents_cursor IS
      -- Bug# 1546081
      --  SELECT *
      SELECT organization_id,
             lpn_content_id,
             parent_lpn_id,
             inventory_item_id
        FROM wms_lpn_contents
       WHERE parent_lpn_id = l_current_lpn
         AND NVL(serial_summary_entry, 2) = 2;

    CURSOR lpn_serial_contents_cursor IS
      -- Bug# 1546081
      --  SELECT *
      SELECT current_organization_id,
             current_subinventory_code,
             current_locator_id,
             inventory_item_id,
             serial_number
        FROM mtl_serial_numbers
       WHERE lpn_id = l_current_lpn;

    -- Bug# 1546081
    -- l_child_lpn             nested_children_cursor%ROWTYPE;
    l_item_quantity          NUMBER;
    l_null_cost_group_val    NUMBER                                  :=  -1 * fnd_api.g_miss_num;

    CURSOR existing_record_cursor IS
      -- Bug# 1546081
      --  SELECT wlc.*
      SELECT wlc.quantity,
             wlc.uom_code
        FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn
       WHERE wlc.parent_lpn_id = p_lpn_id
         AND wlc.organization_id = p_organization_id
         AND wlc.inventory_item_id = p_content_item_id
         AND NVL(wlc.revision, '###') = NVL(p_revision, '###')
         AND NVL(wlc.lot_number, '###') = NVL(p_lot_number, '###')
         AND NVL(wlc.serial_number, '###') = NVL(l_current_serial, '###')
         AND NVL(wlc.cost_group_id, l_null_cost_group_val) = NVL(DECODE(wlpn.lpn_context, 3, wlc.cost_group_id, p_cost_group_id), l_null_cost_group_val)
         AND NVL(wlc.source_type_id, -9999) = NVL(p_source_type_id, -9999)
         AND NVL(wlc.source_header_id, -9999) = NVL(p_source_header_id, -9999)
         AND NVL(wlc.source_line_id, -9999) = NVL(p_source_line_id, -9999)
         AND NVL(wlc.source_line_detail_id, -9999) = NVL(p_source_line_detail_id, -9999)
         AND NVL(wlc.source_name, '###') = NVL(p_source_name, '###')
         AND wlc.parent_lpn_id = wlpn.lpn_id
         AND NVL(wlc.serial_summary_entry, 2) = 2;

    -- Bug# 1546081
    l_existing_record_cursor existing_record_cursor%ROWTYPE;

    CURSOR existing_unpack_record_cursor IS
      -- Bug# 1546081
      --  SELECT wlc.*
      SELECT   wlc.quantity,
               wlc.uom_code,
               wlc.source_type_id,
               wlc.source_header_id,
               wlc.source_line_id,
               wlc.source_line_detail_id,
               wlc.source_name,
               wlc.cost_group_id
         FROM wms_lpn_contents wlc, wms_license_plate_numbers wlpn
         WHERE wlc.parent_lpn_id = p_lpn_id
           AND wlc.organization_id = p_organization_id
           AND wlc.inventory_item_id = p_content_item_id
           AND NVL(wlc.revision, '###') = NVL(p_revision, '###')
           AND NVL(wlc.lot_number, '###') = NVL(p_lot_number, '###')
           AND NVL(wlc.serial_number, '###') = NVL(l_current_serial, '###')
           --AND NVL(wlc.cost_group_id, l_null_cost_group_val) = NVL(DECODE(wlpn.lpn_context, 3, wlc.cost_group_id, NVL(p_cost_group_id, wlc.cost_group_id)), l_null_cost_group_val)
           AND NVL(wlc.source_type_id, -9999) = NVL(p_source_type_id, NVL(wlc.source_type_id, -9999))
           AND NVL(wlc.source_header_id, -9999) = NVL(p_source_header_id, NVL(wlc.source_header_id, -9999))
           AND NVL(wlc.source_line_id, -9999) = NVL(p_source_line_id, NVL(wlc.source_line_id, -9999))
           AND NVL(wlc.source_line_detail_id, -9999) = NVL(p_source_line_detail_id, NVL(wlc.source_line_detail_id, -9999))
           AND NVL(wlc.source_name, '###') = NVL(p_source_name, NVL(wlc.source_name, '###'))
           AND wlc.parent_lpn_id = wlpn.lpn_id
           AND NVL(wlc.serial_summary_entry, 2) = 2
           AND (NVL(wlc.source_name, '###') NOT IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
                OR NVL(p_source_name, '###') IN ('RETURN TO VENDOR', 'RETURN TO RECEIVING', 'RETURN TO CUSTOMER')
               )
      ORDER BY wlc.source_type_id DESC, wlc.source_header_id DESC, wlc.source_line_id DESC, wlc.source_line_detail_id DESC, wlc.source_name DESC;

    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
    CURSOR serial_validation_cursor IS
      SELECT 'Validate Serial'
        FROM DUAL
       WHERE EXISTS( SELECT 'X'
                       FROM mtl_serial_numbers
                      WHERE inventory_item_id = p_content_item_id
                        AND current_organization_id = p_organization_id
                        AND serial_number = l_current_serial
                        AND current_status IN (1, 4, 5, 6, 7));

    CURSOR lot_validation_cursor IS
      SELECT 'Validate Lot'
        FROM DUAL
       WHERE EXISTS( SELECT 'X'
                       FROM mtl_lot_numbers
                      WHERE inventory_item_id = p_content_item_id
                        AND organization_id = p_organization_id
                        AND lot_number = p_lot_number);

    CURSOR one_time_item_cursor IS
      SELECT quantity
        FROM wms_lpn_contents
       WHERE parent_lpn_id = p_lpn_id
         AND organization_id = p_organization_id
         AND item_description = p_content_item_desc
         AND NVL(cost_group_id, l_null_cost_group_val) = NVL(p_cost_group_id, l_null_cost_group_val)
         AND NVL(serial_summary_entry, 2) = l_serial_summary_entry;

    l_temp_record            existing_unpack_record_cursor%ROWTYPE;
    l_temp_lot_exist         VARCHAR2(20);
    l_temp_serial_exist      VARCHAR2(20);
    l_prefix                 VARCHAR2(30);
    l_quantity               NUMBER;
    l_from_number            NUMBER;
    l_to_number              NUMBER;
    l_errorcode              NUMBER;
    l_length                 NUMBER;
    l_padded_length          NUMBER;
    l_current_number         NUMBER;
    l_valid_operation        NUMBER;
    l_converted_quantity     NUMBER;
    l_exploded_table         wms_container_tbl_type;
    l_table_index            BINARY_INTEGER;
    l_temp_outermost_lpn     VARCHAR2(30);
    l_lpn_history_id         NUMBER;
    l_lpn_controlled_flag    NUMBER;
    l_lpn_is_empty           NUMBER;
    l_lpn_context            NUMBER;

    CURSOR nested_container_cursor IS
      -- Bug# 1546081
      --  SELECT *
      SELECT     lpn_id,
                 inventory_item_id
            FROM wms_license_plate_numbers
      START WITH lpn_id = p_lpn_id
      CONNECT BY parent_lpn_id = PRIOR lpn_id;

    l_dynamic_status         NUMBER;
    l_exist_variable         NUMBER;
    l_temp_quantity          NUMBER;
    l_temp_uom_code          VARCHAR2(3);
    l_temp_count             NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT packunpack_container_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

        -- API body
        IF (l_debug = 1) THEN
        mdebug('Call to Packunpack API', G_MESSAGE);
        mdebug('orgid=' ||p_organization_id|| ' sub=' ||p_subinventory|| ' loc=' ||p_locator_id|| ' lpnid=' ||p_lpn_id|| ' cntlpn=' ||p_content_lpn_id, G_INFO);
        mdebug('itemid=' ||p_content_item_id|| ' rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' fmsn=' ||p_from_serial_number|| ' tosn=' ||p_to_serial_number, G_INFO);
        mdebug('qty=' ||p_quantity|| ' uom=' ||p_uom|| ' cg=' ||p_cost_group_id|| ' oper=' ||p_operation|| ' srctype=' ||p_source_type_id||' trxact='||p_trx_action_id, G_INFO);
        END IF;

  /* Validate LPN */
  l_lpn.lpn_id                := p_lpn_id;
  l_lpn.license_plate_number  := NULL;
  l_result                    := validate_lpn(l_lpn, 1);

  IF (l_result = inv_validate.f) THEN
    IF (l_debug = 1) THEN
       mdebug(p_lpn_id || 'is an invalid lpn_id', G_ERROR);
    END IF;
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

    /* Validate all inputs if validation level is set to full */
    IF (p_validation_level = fnd_api.g_valid_level_full) THEN
      /* Validate Content LPN */
      IF (p_content_lpn_id IS NOT NULL) THEN
        l_content_lpn.lpn_id  := p_content_lpn_id;
        l_result              := validate_lpn(l_content_lpn);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_content_lpn_id || 'is and invalid content lpn id', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CONTENT_LPN');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- Check that the content lpn is in fact stored within the given parent lpn
        -- Do this check only for the unpack operation
        IF (p_operation in (2, 5)) THEN
          IF (l_content_lpn.parent_lpn_id <> l_lpn.lpn_id) THEN
            IF (l_debug = 1) THEN
               mdebug('child lpn is not in lpn parent lpn', G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_LPN_NOT_IN_LPN');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Organization ID */
      l_org.organization_id       := p_organization_id;
      l_result                    := inv_validate.ORGANIZATION(l_org);

      IF (l_result = inv_validate.f) THEN
        IF (l_debug = 1) THEN
           mdebug(p_organization_id || 'is not a valid org_id', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Content Item */
      IF (p_content_item_id IS NOT NULL) THEN
        l_content_item.inventory_item_id  := p_content_item_id;
        l_result                          := inv_validate.inventory_item(l_content_item, l_org);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_content_item_id || 'is not a valid content item id', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CONTENT_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Check that a content is given to pack/unpack */
      IF ( p_content_lpn_id IS NULL AND
           p_content_item_id IS NULL AND
           p_content_item_desc IS NULL ) THEN
        -- Note that if the content item description is the only content
        -- value passed in, then we are assuming that it is a one time item
        /* If unpacking everything, then a content is not required */
        IF ( NOT (p_operation = 4 OR (p_unpack_all = 1 AND p_operation = 2)) ) THEN
          IF (l_debug = 1) THEN
            mdebug('no item description for unpack all', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_NO_ITEM_DESC');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate that only a content item OR LPN, not both, is given */
      IF ((p_content_lpn_id IS NOT NULL)
          AND (p_content_item_id IS NOT NULL)
         ) THEN
        IF (l_debug = 1) THEN
           mdebug('Can not specify both content item and container item at same time', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_LPN_AND_ITEM');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate that Subinventory must be given if pack operation and in INV*/
      IF (p_content_item_id IS NOT NULL) THEN
        IF (p_operation = 1) THEN
          IF (l_lpn.lpn_context IN (1, 11)) THEN
            IF (p_subinventory IS NULL) THEN
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END IF;
      END IF;

      /* Validate Subinventory */
      IF (p_subinventory IS NOT NULL) THEN
        l_sub.secondary_inventory_name  := p_subinventory;
        l_result                        := inv_validate.subinventory(l_sub, l_org);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_subinventory || 'is an invalid sub', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SUB');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      --Validate Locator
      IF (l_org.stock_locator_control_code <> 1) THEN
        IF (p_subinventory IS NOT NULL) THEN
          IF (l_org.stock_locator_control_code IN (2, 3)
              OR (l_org.stock_locator_control_code = 4
                  AND l_sub.locator_type IN (2, 3)
                 )
              OR (l_org.stock_locator_control_code = 5
                  AND l_content_item.location_control_code IN (2, 3)
                 )
              OR (l_org.stock_locator_control_code = 4
                  AND l_sub.locator_type = 5
                  AND l_content_item.location_control_code IN (2, 3)
                 )
             ) THEN
            --IF (l_org.stock_locator_control_code = 4 AND
            --(l_sub.locator_type <> 1 OR l_sub.locator_type = 5
            --AND l_content_item.location_control_code <> 1)) THEN
            --IF (l_org.stock_locator_control_code = 5 AND
            --l_content_item.location_control_code <> 1) THEN
            IF (p_locator_id IS NULL) THEN
              IF (l_debug = 1) THEN
                 mdebug('Missing required locator', G_ERROR);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOC');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;

            l_locator.inventory_location_id  := p_locator_id;
            l_result                         := inv_validate.validatelocator(l_locator, l_org, l_sub);

            IF (l_result = inv_validate.f) THEN
              IF (l_debug = 1) THEN
                 mdebug(p_locator_id || ' is an invalid locator_id', G_ERROR);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOC');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          --END IF;
          END IF;
        END IF;
      END IF;

      /* Validate Revision */
      IF (p_content_item_id IS NOT NULL) THEN
        IF (l_content_item.revision_qty_control_code = 2) THEN
          IF (p_revision IS NOT NULL) THEN
            l_result  := inv_validate.revision(p_revision, l_org, l_content_item);

            IF (l_result = inv_validate.f) THEN
              IF (l_debug = 1) THEN
                 mdebug(p_revision || ' is an invalid revision', G_ERROR);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_REV');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            IF (l_debug = 1) THEN
               mdebug('Mission required revision', G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_REV');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Lot */
      /* Sub and locator might not be given in the case of pre-packing */
      IF (p_content_item_id IS NOT NULL) THEN
        IF (l_content_item.lot_control_code = 2
            AND NOT (NVL(p_trx_action_id, -9999) = inv_globals.g_action_inv_lot_split)
            AND NOT (NVL(p_trx_action_id, -9999) = inv_globals.g_action_inv_lot_merge)
           ) THEN
          IF (p_lot_number IS NOT NULL) THEN
            -- Do lot validation only if the container/item is in INV,
            -- not WIP or REC since dynamic lots are possible in WIP and REC.
            IF (l_lpn.lpn_context IN (1, 11)) THEN
              IF (p_subinventory IS NOT NULL) THEN
                l_lot.lot_number  := p_lot_number;

                SELECT COUNT(*)
                  INTO l_temp_count
                  FROM mtl_lot_numbers
                 WHERE organization_id = p_organization_id
                   AND lot_number = p_lot_number
                   AND inventory_item_id = p_content_item_id;

                IF l_temp_count > 0 THEN
                  l_result  := inv_validate.lot_number(l_lot, l_org, l_content_item, l_sub, l_locator, p_revision);

                  IF (l_result = inv_validate.f) THEN
                    IF (l_debug = 1) THEN
                       mdebug(p_lot_number || ' is an invalid lot number', G_ERROR);
                    END IF;
                    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOT');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_error;
                  END IF;
                END IF;
              ELSE
                -- Subinventory was not given so will need to do
                -- alternative non-standard lot number validation.
                OPEN lot_validation_cursor;
                FETCH lot_validation_cursor INTO l_temp_lot_exist;

                IF lot_validation_cursor%NOTFOUND THEN
                  IF (l_debug = 1) THEN
                     mdebug(p_lot_number || ' is an invalid lot number', G_ERROR);
                  END IF;
                  fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LOT');
                  fnd_msg_pub.ADD;
                  RAISE fnd_api.g_exc_error;
                END IF;

                CLOSE lot_validation_cursor;
              END IF;
            ELSE
              IF (l_debug = 1) THEN
                 mdebug('Container not in INV', G_MESSAGE);
              END IF;
            END IF;
          ELSE
            IF (l_debug = 1) THEN
               mdebug('Missing required lot', G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Quantity if item is not serial controlled */
      IF (p_content_item_id IS NOT NULL) THEN
        IF (l_content_item.serial_number_control_code IN (1, 6)
            OR l_lpn.lpn_context = WMS_CONTAINER_PVT.LPN_PREPACK_FOR_WIP
           ) THEN
          IF (p_quantity <= 0) THEN
            IF (l_debug = 1) THEN
               mdebug('Requested a negative item qty', G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_NEG_ITEM_QTY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          ELSE
            l_quantity  := p_quantity;
          END IF;
        END IF;
      END IF;

      /* Check that if a content LPN is given, then quantity, */
      /* if given, must be equal to 1 */
      IF ((p_content_item_id IS NULL)
          AND (p_content_lpn_id IS NOT NULL)
         ) THEN
        IF (p_quantity IS NOT NULL) THEN
          IF (p_quantity <> 1) THEN
            IF (l_debug = 1) THEN
               mdebug('For container item unpack quantitiy must be 1', G_ERROR);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_INVALID_QTY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        ELSE
          l_quantity  := 1;
        END IF;
      END IF;

      -- Validate Serial
      -- Sub and locator might not be given in the case of pre-packing
      IF (p_content_item_id IS NOT NULL) THEN
                        IF (l_content_item.serial_number_control_code NOT IN (1, 6)) THEN
                                IF ((p_from_serial_number IS NOT NULL) AND (p_to_serial_number IS NOT NULL)) THEN
                                        IF (l_debug = 1) THEN
                                        mdebug('Call this API to parse sn ' || p_from_serial_number||'-'||p_to_serial_number, G_MESSAGE);
                                        END IF;
                                        IF (NOT mtl_serial_check.inv_serial_info(p_from_serial_number, p_to_serial_number, l_prefix, l_quantity, l_from_number, l_to_number, l_errorcode)) THEN
                                                IF (l_debug = 1) THEN
                                                mdebug('Invalid serial number given in range', G_ERROR);
                                                END IF;
                                                fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
                                                fnd_msg_pub.ADD;
                                                RAISE fnd_api.g_exc_error;
                                        END IF;

                                        -- Check that in the case of a range of serial numbers, that the
                                        -- inputted p_quantity equals the amount of items in the serial range.
                                        IF (p_quantity IS NOT NULL) THEN
                                                IF (p_quantity <> l_quantity) THEN
                                                  IF (l_debug = 1) THEN
                                                  mdebug('Serial range quantity '||l_quantity||' not the same as given qty '||p_quantity, G_ERROR);
                                                  END IF;
                                                  fnd_message.set_name('WMS', 'WMS_CONT_INVALID_X_QTY');
                                                  fnd_msg_pub.ADD;
                                                  RAISE fnd_api.g_exc_error;
                                                END IF;
                                        END IF;

                                        -- Get the serial number length.
                                        -- Note that the from and to serial numbers must be of the same length.
                                        l_length  := LENGTH(p_from_serial_number);

                                        -- If lpn context is not inventory, bypass serial number validation
                                        IF (NOT l_lpn.lpn_context IN (1, 11)) THEN
                                                -- Initialize the current pointer variables
                                                l_current_serial  := p_from_serial_number;
                                                l_current_number  := l_from_number;

                                                LOOP
                                                        -- Get the serial number current status for the current
                                                        -- serial number to check if it was dynamically generated
                                                        SELECT COUNT(*)
                                                          INTO l_dynamic_status
                                                          FROM mtl_serial_numbers
                                                         WHERE inventory_item_id = p_content_item_id
                                                           AND serial_number = l_current_serial
                                                           AND current_organization_id = p_organization_id
                                                           AND current_status = 6;

                                                        IF ((p_subinventory IS NOT NULL) AND (l_dynamic_status = 0)) THEN
                                                                l_serial.serial_number  := l_current_serial;
								l_lot.lot_number := p_lot_number; -- Added for bug 8775286
                                                                l_result                := inv_validate.validate_serial(l_serial, l_org, l_content_item, l_sub, l_lot, l_locator, p_revision);

                                                                IF (l_result = inv_validate.f) THEN
                                                                  IF (l_debug = 1) THEN
                                                                  mdebug(l_current_serial || ' is not a valid serial number', G_ERROR);
                                                                  END IF;
                                                                  fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
                                                                  fnd_msg_pub.ADD;
                                                                  RAISE fnd_api.g_exc_error;
                                                                END IF;
                                                        ELSE
                                                                -- Either the subinventory was not given or
                                                                -- the serial number was dynamically generated.  We will
                                                                -- need to do alternative non-standard serial number validation.
                                                                OPEN serial_validation_cursor;
                                                                FETCH serial_validation_cursor INTO l_temp_serial_exist;

                                                                IF serial_validation_cursor%NOTFOUND THEN
                                                                        IF (l_debug = 1) THEN
                                                                        mdebug(l_current_serial || ' is not a valid serial number', G_ERROR);
                                                                        END IF;
                                                                        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
                                                                        fnd_msg_pub.ADD;
                                                                        RAISE fnd_api.g_exc_error;
                                                                END IF;

                                                                CLOSE serial_validation_cursor;
                                                        END IF;

                                                        EXIT WHEN l_current_serial = p_to_serial_number;
                                                        /* Increment the current serial number */
                                                        l_current_number  := l_current_number + 1;
                                                        l_padded_length   := l_length - LENGTH(l_current_number);

                                                        IF l_prefix IS NOT NULL THEN
                                                           l_current_serial := RPAD(l_prefix, l_padded_length, '0') || l_current_number;
                                                        ELSE
                                                                l_current_serial := Rpad('@',l_padded_length+1,'0') || l_current_number;
                                                           l_current_serial := Substr(l_current_serial,2);
                                                        END IF;

                                                        -- Bug 2375043
                                                        --l_current_serial := RPAD(l_prefix, l_padded_length, '0') ||
                                                        --l_current_number;
                                                END LOOP;
                                                        END IF;
                                                                ELSIF (l_lpn.lpn_context = WMS_CONTAINER_PVT.LPN_PREPACK_FOR_WIP) THEN
                                                                  -- If lpn context is prepacked for WIP, user does not need to specify sn
                                                                  -- Needs to be treated like a non serial item, no mtl_serial_number entry
                                                                  -- except serial_summary_entry flag should be set.
                                                                  l_serial_summary_entry  := 1;
                                                                ELSE
                                                         IF (l_debug = 1) THEN
                                                         mdebug('Missing require serial number', G_ERROR);
                                                         END IF;
                                                         fnd_message.set_name('WMS', 'WMS_CONT_MISS_SER_NUM');
                                                         fnd_msg_pub.ADD;
                                                         RAISE fnd_api.g_exc_error;
                                                                END IF;
                                                        END IF;
                                                END IF;

      /* Validate content item UOM */
      IF (p_content_item_id IS NOT NULL) THEN
        l_result  := inv_validate.uom(p_uom, l_org, l_content_item);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_uom || ' is an invalid UOM', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_UOM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate the operation */
      IF ( p_operation < 1 OR p_operation > 5 ) THEN
        IF (l_debug = 1) THEN
          mdebug(p_operation || ' is an invalid operation type', G_ERROR);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_OPERATION');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate the enforce weight and volume constraint flag */
      IF (p_enforce_wv_constraints IS NOT NULL) THEN
        IF ((p_enforce_wv_constraints <> 1) AND (p_enforce_wv_constraints <> 2)) THEN
          IF (l_debug = 1) THEN
             mdebug(p_enforce_wv_constraints || ' is an invalid constraint type', G_MESSAGE);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CONSTRAINT');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Cost Group */
      IF (p_cost_group_id IS NOT NULL) THEN
        l_result  := inv_validate.cost_group(p_cost_group_id, p_organization_id);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_cost_group_id || ' is an invalid cost group is', G_ERROR);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CST_GRP');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;
    /* End of Input Validation */

    IF ( p_operation = 5 ) THEN
      -- Set operation to unpack but ignore the lots/and serials
      l_operation := 2;
      l_ignore_item_controls := 1;
    ELSIF ( l_lpn.lpn_context = 4 AND p_trx_action_id = 8 ) THEN
      -- Change operation to new Adjust type
      l_operation := 3;
    ELSIF ( p_unpack_all = 1 ) THEN
      -- Change operation to new Unpack All type
      l_operation := 4;
    END IF;

    WMS_CONTAINER_PVT.PackUnpack_Container (
      p_api_version            => p_api_version
    , p_init_msg_list          => p_init_msg_list
    , p_commit                 => p_commit
    , p_validation_level       => p_validation_level
    , x_return_status          => x_return_status
    , x_msg_count              => x_msg_count
    , x_msg_data               => x_msg_data
    , p_lpn_id                 => p_lpn_id
    , p_content_lpn_id         => p_content_lpn_id
    , p_content_item_id        => p_content_item_id
    , p_content_item_desc      => p_content_item_desc
    , p_revision               => p_revision
    , p_lot_number             => p_lot_number
    , p_from_serial_number     => p_from_serial_number
    , p_to_serial_number       => p_to_serial_number
    , p_quantity               => p_quantity
    , p_uom                    => p_uom
    , p_sec_quantity           => p_sec_quantity --INCONV kkillams
    , p_sec_uom                => p_sec_uom --INCONV kkillams
    , p_organization_id        => p_organization_id
    , p_subinventory           => p_subinventory
    , p_locator_id             => p_locator_id
    , p_enforce_wv_constraints => p_enforce_wv_constraints
    , p_operation              => l_operation
    , p_cost_group_id          => p_cost_group_id
    , p_source_type_id         => p_source_type_id
    , p_source_header_id       => p_source_header_id
    , p_source_name            => p_source_name
    , p_source_line_id         => p_source_line_id
    , p_source_line_detail_id  => p_source_line_detail_id
    , p_unpack_all             => p_unpack_all
    , p_ignore_item_controls   => l_ignore_item_controls );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO packunpack_container_pub;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO packunpack_container_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO packunpack_container_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END packunpack_container;

  PROCEDURE pack_prepack_container(
    p_api_version        IN     NUMBER,
    p_init_msg_list      IN     VARCHAR2 := fnd_api.g_false,
    p_commit             IN     VARCHAR2 := fnd_api.g_false,
    p_validation_level   IN     NUMBER := fnd_api.g_valid_level_full,
    x_return_status      OUT    NOCOPY VARCHAR2,
    x_msg_count          OUT    NOCOPY NUMBER,
    x_msg_data           OUT    NOCOPY VARCHAR2,
    p_lpn_id             IN     NUMBER,
    p_content_item_id    IN     NUMBER := NULL,
    p_revision           IN     VARCHAR2 := NULL,
    p_lot_number         IN     VARCHAR2 := NULL,
    p_from_serial_number IN     VARCHAR2 := NULL,
    p_to_serial_number   IN     VARCHAR2 := NULL,
    p_quantity           IN     NUMBER := 1,
    p_uom                IN     VARCHAR2 := NULL,
    p_organization_id    IN     NUMBER,
    p_operation          IN     NUMBER,
    p_source_type_id     IN     NUMBER := NULL
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)        := 'pack_prepack_container';
    l_api_version CONSTANT NUMBER              := 1.0;
    l_lpn                  lpn;
    l_content_lpn          lpn;
    l_content_item         inv_validate.item;
    l_org                  inv_validate.org;
    l_lot                  inv_validate.lot;
    l_serial               inv_validate.serial;
    l_current_serial       VARCHAR2(30)        := p_from_serial_number;
    l_result               NUMBER;
    l_serial_summary_entry NUMBER              := 2;

    /* FP-J Lot/Serial Support Enhancements
     * Add current status of resides in receiving
     */
    CURSOR serial_validation_cursor IS
      SELECT 'Validate Serial'
        FROM DUAL
       WHERE EXISTS( SELECT 'X'
                       FROM mtl_serial_numbers
                      WHERE inventory_item_id = p_content_item_id
                        AND current_organization_id = p_organization_id
                        AND serial_number = l_current_serial
                        AND current_status IN (1, 5, 6, 7));

    l_temp_serial_exist    VARCHAR2(20);
    l_prefix               VARCHAR2(30);
    l_quantity             NUMBER;
    l_from_number          NUMBER;
    l_to_number            NUMBER;
    l_errorcode            NUMBER;
    l_length               NUMBER;
    l_padded_length        NUMBER;
    l_current_number       NUMBER;
    l_table_index          BINARY_INTEGER;
    l_dynamic_status       NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT pack_prepack_container_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;

    -- API body
    IF (l_debug = 1) THEN
      mdebug('Call to Pack_Prepack_Container API', G_MESSAGE);
      mdebug('lpnid=' ||p_lpn_id|| ' orgid=' ||p_organization_id||' itemid=' ||p_content_item_id, G_INFO);
      mdebug('rev=' ||p_revision|| ' lot=' ||p_lot_number|| ' fmsn=' ||p_from_serial_number|| ' tosn=' ||p_to_serial_number, G_INFO);
      mdebug('qty=' ||p_quantity|| ' uom=' ||p_uom|| ' oper=' ||p_operation|| ' srctype=' ||p_source_type_id, G_INFO);
    END IF;

    /* Validate all inputs if validation level is set to full */
    IF (p_validation_level = fnd_api.g_valid_level_full) THEN
      /* Validate LPN */
      l_lpn.lpn_id                := p_lpn_id;
      l_lpn.license_plate_number  := NULL;
      l_result                    := validate_lpn(l_lpn);

      IF (l_result = inv_validate.f) THEN
        IF (l_debug = 1) THEN
           mdebug(p_lpn_id || 'is an invalid lpn_id', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_LPN');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Organization ID */
      l_org.organization_id       := p_organization_id;
      l_result                    := inv_validate.ORGANIZATION(l_org);

      IF (l_result = inv_validate.f) THEN
        IF (l_debug = 1) THEN
           mdebug(p_organization_id || 'is not a valid org_id', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;

      /* Validate Content Item */
      IF (p_content_item_id IS NOT NULL) THEN
        l_content_item.inventory_item_id  := p_content_item_id;
        l_result                          := inv_validate.inventory_item(l_content_item, l_org);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_content_item_id || 'is not a valid content item id', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_CONTENT_ITEM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate Revision */
      IF (p_content_item_id IS NOT NULL) THEN
        IF (l_content_item.revision_qty_control_code = 2) THEN
          IF (p_revision IS NOT NULL) THEN
            l_result  := inv_validate.revision(p_revision, l_org, l_content_item);

            IF (l_result = inv_validate.f) THEN
              IF (l_debug = 1) THEN
                 mdebug(p_revision || ' is an invalid revision', 1);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_REV');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;
          ELSE
            IF (l_debug = 1) THEN
               mdebug('Mission required revision', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_REV');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Lot */
      /* Sub and locator might not be given in the case of pre-packing */
      IF (p_content_item_id IS NOT NULL) THEN
        IF (l_content_item.lot_control_code = 2) THEN
          IF (p_lot_number IS NULL) THEN
            IF (l_debug = 1) THEN
               mdebug('Missing required lot', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_REQ_LOT');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate Quantity if item is not serial controlled */
      IF (p_content_item_id IS NOT NULL) THEN
        IF (l_content_item.serial_number_control_code IN (1, 6)
            OR l_lpn.lpn_context = WMS_CONTAINER_PVT.LPN_PREPACK_FOR_WIP
           ) THEN
          IF (p_quantity <= 0) THEN
            IF (l_debug = 1) THEN
               mdebug('Requested a negative item qty', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_NEG_ITEM_QTY');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          ELSE
            l_quantity  := p_quantity;
          END IF;
        END IF;
      END IF;

      /* Validate Serial */
      /* Sub and locator might not be given in the case of pre-packing */
      IF (p_content_item_id IS NOT NULL) THEN
        IF (l_content_item.serial_number_control_code NOT IN (1, 6)) THEN
          IF ((p_from_serial_number IS NOT NULL)
              AND (p_to_serial_number IS NOT NULL)
             ) THEN
            /* Call this API to parse the serial numbers into prefixes and numbers */
            IF (NOT mtl_serial_check.inv_serial_info(p_from_serial_number, p_to_serial_number, l_prefix, l_quantity, l_from_number, l_to_number, l_errorcode)) THEN
              IF (l_debug = 1) THEN
                 mdebug('Invalid serial number given in range', 1);
              END IF;
              fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
            END IF;

            -- Check that in the case of a range of serial numbers, that the
            -- inputted p_quantity equals the amount of items in the serial range.
            IF (p_quantity IS NOT NULL) THEN
              IF (p_quantity <> l_quantity) THEN
                IF (l_debug = 1) THEN
                   mdebug('Serial range quantity '||l_quantity||' not the same as given qty '||p_quantity, G_ERROR);
                END IF;
                fnd_message.set_name('WMS', 'WMS_CONT_INVALID_X_QTY');
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

            -- Get the serial number length.
            -- Note that the from and to serial numbers must be of the same length.
            l_length  := LENGTH(p_from_serial_number);

            -- If lpn context is not inventory, bypass serial number validation
            IF (NOT l_lpn.lpn_context IN (1, 11)) THEN
              -- Initialize the current pointer variables
              l_current_serial  := p_from_serial_number;
              l_current_number  := l_from_number;

              LOOP
                -- Get the serial number current status for the current
                -- serial number to check if it was dynamically generated
                SELECT COUNT(*)
                  INTO l_dynamic_status
                  FROM mtl_serial_numbers
                 WHERE inventory_item_id = p_content_item_id
                   AND serial_number = l_current_serial
                   AND current_organization_id = p_organization_id
                   AND current_status = 6;

                IF ((l_dynamic_status = 0)) THEN
                  NULL;
                ELSE
                  -- Either the subinventory was not given or
                  -- the serial number was dynamically generated.  We will
                  -- need to do alternative non-standard serial number validation.
                  OPEN serial_validation_cursor;
                  FETCH serial_validation_cursor INTO l_temp_serial_exist;

                  IF serial_validation_cursor%NOTFOUND THEN
                    IF (l_debug = 1) THEN
                       mdebug(l_current_serial || ' is not a valid serial number', 1);
                    END IF;
                    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_SER');
                    fnd_msg_pub.ADD;
                    RAISE fnd_api.g_exc_error;
                  END IF;

                  CLOSE serial_validation_cursor;
                END IF;

                EXIT WHEN l_current_serial = p_to_serial_number;
                /* Increment the current serial number */
                l_current_number  := l_current_number + 1;
                l_padded_length   := l_length - LENGTH(l_current_number);
                IF l_prefix IS NOT NULL THEN
                   l_current_serial := RPAD(l_prefix, l_padded_length, '0') ||
                     l_current_number;
                 ELSE
                   l_current_serial := Rpad('@',l_padded_length+1,'0')
                     || l_current_number;
                   l_current_serial := Substr(l_current_serial,2);
                END IF;
                -- Bug 2375043
                --l_current_serial := RPAD(l_prefix, l_padded_length, '0') || l_current_number;
              END LOOP;
            END IF;
          ELSIF (l_lpn.lpn_context = WMS_CONTAINER_PVT.LPN_PREPACK_FOR_WIP) THEN
            -- If lpn context is prepacked for WIP, user does not need to specify sn
            -- Needs to be treated like a non serial item, no mtl_serial_number entry
            -- except serial_summary_entry flag should be set.
            l_serial_summary_entry  := 1;
          ELSE
            IF (l_debug = 1) THEN
               mdebug('Missing require serial number', 1);
            END IF;
            fnd_message.set_name('WMS', 'WMS_CONT_MISS_SER_NUM');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END IF;

      /* Validate content item UOM */
      IF (p_content_item_id IS NOT NULL) THEN
        l_result  := inv_validate.uom(p_uom, l_org, l_content_item);

        IF (l_result = inv_validate.f) THEN
          IF (l_debug = 1) THEN
             mdebug(p_uom || ' is an invalid UOM', 1);
          END IF;
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_UOM');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      /* Validate the operation */
      IF ((p_operation <> 1)) THEN
        IF (l_debug = 1) THEN
           mdebug(p_operation || ' is an invalid operation type', 1);
        END IF;
        fnd_message.set_name('WMS', 'WMS_CONT_INVALID_OPERATION');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    /* End of Input Validation */

    WMS_CONTAINER_PVT.Pack_Prepack_Container (
      p_api_version        => p_api_version
    , p_init_msg_list      => p_init_msg_list
    , p_commit             => p_commit
    , p_validation_level   => p_validation_level
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    , p_lpn_id             => p_lpn_id
    , p_content_item_id    => p_content_item_id
    , p_revision           => p_revision
    , p_lot_number         => p_lot_number
    , p_from_serial_number => p_from_serial_number
    , p_to_serial_number   => p_to_serial_number
    , p_quantity           => p_quantity
    , p_uom                => p_uom
    , p_organization_id    => p_organization_id
    , p_operation          => p_operation
    , p_source_type_id     => p_source_type_id );

    IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO pack_prepack_container_pub;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO pack_prepack_container_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO pack_prepack_container_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END pack_prepack_container;

  -- ----------------------------------------------------------------------------------
  -- ----------------------------------------------------------------------------------
  PROCEDURE explode_lpn(
    p_api_version     IN     NUMBER,
    p_init_msg_list   IN     VARCHAR2 := fnd_api.g_false,
    p_commit          IN     VARCHAR2 := fnd_api.g_false,
    x_return_status   OUT    NOCOPY VARCHAR2,
    x_msg_count       OUT    NOCOPY NUMBER,
    x_msg_data        OUT    NOCOPY VARCHAR2,
    p_lpn_id          IN     NUMBER,
    p_explosion_level IN     NUMBER := 0,
    x_content_tbl     OUT    NOCOPY wms_container_tbl_type
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    WMS_CONTAINER_PVT.explode_lpn(
      p_api_version=> p_api_version,
      p_init_msg_list=> p_init_msg_list,
      p_commit=> p_commit,
      x_return_status=> x_return_status,
      x_msg_count=> x_msg_count,
      x_msg_data=> x_msg_data,
      p_lpn_id=> p_lpn_id,
      p_explosion_level=> p_explosion_level,
      x_content_tbl=> x_content_tbl
    );
  END explode_lpn;

  -- ----------------------------------------------------------------------------------
  -- ----------------------------------------------------------------------------------
  PROCEDURE container_required_qty(
    p_api_version       IN     NUMBER,
    p_init_msg_list     IN     VARCHAR2 := fnd_api.g_false,
    p_commit            IN     VARCHAR2 := fnd_api.g_false,
    x_return_status     OUT    NOCOPY VARCHAR2,
    x_msg_count         OUT    NOCOPY NUMBER,
    x_msg_data          OUT    NOCOPY VARCHAR2,
    p_source_item_id    IN     NUMBER,
    p_source_qty        IN     NUMBER,
    p_source_qty_uom    IN     VARCHAR2,
    p_qty_per_cont      IN     NUMBER := NULL,
    p_qty_per_cont_uom  IN     VARCHAR2 := NULL,
    p_organization_id   IN     NUMBER,
    p_dest_cont_item_id IN OUT NOCOPY NUMBER,
    p_qty_required      OUT    NOCOPY NUMBER
  ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    WMS_CONTAINER_PVT.container_required_qty(
      p_api_version=> p_api_version,
      p_init_msg_list=> p_init_msg_list,
      p_commit=> p_commit,
      x_return_status=> x_return_status,
      x_msg_count=> x_msg_count,
      x_msg_data=> x_msg_data,
      p_source_item_id=> p_source_item_id,
      p_source_qty=> p_source_qty,
      p_source_qty_uom=> p_source_qty_uom,
      p_qty_per_cont=> p_qty_per_cont,
      p_qty_per_cont_uom=> p_qty_per_cont_uom,
      p_organization_id=> p_organization_id,
      p_dest_cont_item_id=> p_dest_cont_item_id,
      p_qty_required=> p_qty_required
    );
  END container_required_qty;

  -- ----------------------------------------------------------------------------------
  -- ----------------------------------------------------------------------------------

  PROCEDURE prepack_lpn_cp(
    errbuf                    OUT    NOCOPY VARCHAR2,
    retcode                   OUT    NOCOPY NUMBER,
    p_api_version             IN     NUMBER,
    p_organization_id         IN     NUMBER,
    p_subinventory            IN     VARCHAR2 := NULL,
    p_locator_id              IN     NUMBER := NULL,
    p_inventory_item_id       IN     NUMBER,
    p_revision                IN     VARCHAR2 := NULL,
    p_lot_number              IN     VARCHAR2 := NULL,
    p_quantity                IN     NUMBER,
    p_uom                     IN     VARCHAR2,
    p_source                  IN     NUMBER,
    p_serial_number_from      IN     VARCHAR2 := NULL,
    p_serial_number_to        IN     VARCHAR2 := NULL,
    p_container_item_id       IN     NUMBER := NULL,
    p_cont_revision           IN     VARCHAR2 := NULL,
    p_cont_lot_number         IN     VARCHAR2 := NULL,
    p_cont_serial_number_from IN     VARCHAR2 := NULL,
    p_cont_serial_number_to   IN     VARCHAR2 := NULL,
    p_lpn_sealed_flag         IN     NUMBER,
    p_print_label             IN     NUMBER,
    p_print_content_report    IN     NUMBER
  ) IS
    l_api_name    CONSTANT VARCHAR2(30)  := 'Prepack_LPN_CP';
    l_api_version CONSTANT NUMBER        := 1.0;
    l_lpn                  lpn;
    l_result               NUMBER;
    p_init_msg_list        VARCHAR2(10)  := fnd_api.g_false;
    p_commit               VARCHAR2(10)  := fnd_api.g_false;
    x_return_status        VARCHAR2(4);
    x_msg_count            NUMBER;
    x_msg_data             VARCHAR2(300);
    ret                    BOOLEAN;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT prepack_lpn_cp_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    -- Start API body

    -- Call Prepack LPN
    WMS_CONTAINER_PVT.prepack_lpn(
      p_api_version=> p_api_version,
      p_init_msg_list=> p_init_msg_list,
      p_commit=> p_commit,
      x_return_status=> x_return_status,
      x_msg_count=> x_msg_count,
      x_msg_data=> x_msg_data,
      p_organization_id=> p_organization_id,
      p_subinventory=> p_subinventory,
      p_locator_id=> p_locator_id,
      p_inventory_item_id=> p_inventory_item_id,
      p_revision=> p_revision,
      p_lot_number=> p_lot_number,
      p_quantity=> p_quantity,
      p_uom=> p_uom,
      p_source=> p_source,
      p_serial_number_from=> p_serial_number_from,
      p_serial_number_to=> p_serial_number_to,
      p_container_item_id=> p_container_item_id,
      p_cont_revision=> p_cont_revision,
      p_cont_lot_number=> p_cont_lot_number,
      p_cont_serial_number_from=> p_cont_serial_number_from,
      p_cont_serial_number_to=> p_cont_serial_number_to,
      p_lpn_sealed_flag=> p_lpn_sealed_flag,
      p_print_label=> p_print_label,
      p_print_content_report=> p_print_content_report
    );

    IF (x_return_status = fnd_api.g_ret_sts_success) THEN
      ret      := fnd_concurrent.set_completion_status('NORMAL', x_msg_data);
      retcode  := 0;
    ELSE
      ret      := fnd_concurrent.set_completion_status('ERROR', x_msg_data);
      retcode  := 2;
      errbuf   := x_msg_data;
    END IF;

    -- End of API body

    -- Standard check of p_commit.
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO prepack_lpn_cp_pub;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO prepack_lpn_cp_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO prepack_lpn_cp_pub;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END prepack_lpn_cp;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------
FUNCTION Validate_LPN( p_lpn IN OUT nocopy LPN, p_lock IN NUMBER := 2) RETURN NUMBER
IS

BEGIN
   RETURN WMS_CONTAINER_PVT.Validate_LPN (
           p_lpn  => p_lpn
         , p_lock => p_lock );
EXCEPTION
   WHEN OTHERS THEN
      RETURN F;
END Validate_LPN;

  -- ----------------------------------------------------------------------------------
  -- ----------------------------------------------------------------------------------

  FUNCTION lpn_pack_complete(p_revert NUMBER := 0)
    RETURN BOOLEAN IS
    lpn_weight NUMBER;
    lpn_volume NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN
    IF (p_revert = 1) THEN
      -- Remove all rows from the global wt/vol changes table
      FOR i IN 1 .. g_lpn_wt_vol_changes.COUNT LOOP
        SELECT gross_weight,
               content_volume
          INTO lpn_weight,
               lpn_volume
          FROM wms_license_plate_numbers
         WHERE lpn_id = g_lpn_wt_vol_changes(i).lpn_id;

        -- Bug5659809: update last_update_date and last_update_by as well
        UPDATE wms_license_plate_numbers
           SET gross_weight = lpn_weight - g_lpn_wt_vol_changes(i).gross_weight_change
             , content_volume = lpn_volume - g_lpn_wt_vol_changes(i).content_volume_change
             , last_update_date = SYSDATE
             , last_updated_by = fnd_global.user_id
         WHERE lpn_id = g_lpn_wt_vol_changes(i).lpn_id;
      END LOOP;
    END IF;

    g_lpn_wt_vol_changes.DELETE;
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END lpn_pack_complete;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Merge_Up_LPN (
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Get_Default_Secondary_Quantity';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';
l_msgdata              VARCHAR2(1000);

-- Variables for validation
l_result                 NUMBER;
l_org                    inv_validate.org;
l_lpn                    LPN;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, G_ERROR);
  END IF;

  l_progress := '100';
  -- Validate Organization ID
  l_org.organization_id  := p_organization_id;
  l_result               := inv_validate.ORGANIZATION(l_org);

  IF ( l_result = INV_Validate.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_organization_id || ' is not a valid org id', G_ERROR);
    END IF;
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  l_progress := '200';
  -- Validate LPN
  l_lpn.lpn_id := p_outermost_lpn_id;
  l_result     := Validate_LPN(l_lpn);

  IF ( l_result = INV_Validate.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_outermost_lpn_id || ' is an invalid lpn id', G_ERROR);
    END IF;
    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '300';
  -- Validate if LPN is valid for this transaction
  l_result := WMS_CONTAINER_PVT.Validate_LPN (
    p_organization_id => p_organization_id
  , p_lpn_id          => p_outermost_lpn_id
  , p_validation_type => WMS_CONTAINER_PVT.G_RECONFIGURE_LPN );

  IF ( l_result = WMS_CONTAINER_PVT.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_outermost_lpn_id || ' cannot be used for merge up', G_ERROR);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '400';
  WMS_CONTAINER_PVT.Merge_Up_LPN (
    p_api_version      => p_api_version
  , p_init_msg_list    => p_init_msg_list
  , p_commit           => p_commit
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  , p_organization_id  => p_organization_id
  , p_outermost_lpn_id => p_outermost_lpn_id );

  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), 1);
      mdebug('msg: '||l_msgdata, 1);
    END IF;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), 1);
    END IF;
END Merge_Up_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Break_Down_LPN (
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Break_Down_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';
l_msgdata              VARCHAR2(1000);

-- Variables for validation
l_result                 NUMBER;
l_org                    inv_validate.org;
l_lpn                    LPN;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, G_ERROR);
  END IF;

  l_progress := '100';
  -- Validate Organization ID
  l_org.organization_id  := p_organization_id;
  l_result               := inv_validate.ORGANIZATION(l_org);

  IF ( l_result = INV_Validate.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_organization_id || ' is not a valid org id', G_ERROR);
    END IF;
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  l_progress := '200';
  -- Validate LPN
  l_lpn.lpn_id := p_outermost_lpn_id;
  l_result     := Validate_LPN(l_lpn);

  IF ( l_result = INV_Validate.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_outermost_lpn_id || ' is an invalid lpn id', G_ERROR);
    END IF;
    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '300';
  -- Validate if LPN is valid for this transaction
  l_result := WMS_CONTAINER_PVT.Validate_LPN (
    p_organization_id => p_organization_id
  , p_lpn_id          => p_outermost_lpn_id
  , p_validation_type => WMS_CONTAINER_PVT.G_RECONFIGURE_LPN );

  IF ( l_result = WMS_CONTAINER_PVT.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_outermost_lpn_id || ' cannot be used for merge up', G_ERROR);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '400';
  WMS_CONTAINER_PVT.Break_Down_LPN (
    p_api_version      => p_api_version
  , p_init_msg_list    => p_init_msg_list
  , p_commit           => p_commit
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  , p_organization_id  => p_organization_id
  , p_outermost_lpn_id => p_outermost_lpn_id );

  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), 1);
      mdebug('msg: '||l_msgdata, 1);
    END IF;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), 1);
    END IF;
END Break_Down_LPN;

-- ----------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------

PROCEDURE Initialize_LPN (
  p_api_version             IN         NUMBER
, p_init_msg_list           IN         VARCHAR2 := fnd_api.g_false
, p_commit                  IN         VARCHAR2 := fnd_api.g_false
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN         NUMBER
, p_outermost_lpn_id        IN         NUMBER
) IS
l_api_name    CONSTANT VARCHAR2(30) := 'Initialize_LPN';
l_api_version CONSTANT NUMBER       := 1.0;
l_debug                NUMBER       := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
l_progress             VARCHAR2(10) := '0';
l_msgdata              VARCHAR2(1000);

-- Variables for validation
l_result NUMBER;
l_org    inv_validate.org;
l_lpn    LPN;

BEGIN
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
    fnd_message.set_name('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list) THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status  := fnd_api.g_ret_sts_success;

  IF ( l_debug = 1 ) THEN
    mdebug(l_api_name || ' Entered ' || g_pkg_version, G_ERROR);
  END IF;

  l_progress := '100';
  -- Validate Organization ID
  l_org.organization_id  := p_organization_id;
  l_result               := inv_validate.ORGANIZATION(l_org);

  IF ( l_result = INV_Validate.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_organization_id || ' is not a valid org id', G_ERROR);
    END IF;
    fnd_message.set_name('WMS', 'WMS_CONT_INVALID_ORG');
    fnd_msg_pub.ADD;
    RAISE fnd_api.g_exc_error;
  END IF;

  l_progress := '200';
  -- Validate LPN
  l_lpn.lpn_id := p_outermost_lpn_id;
  l_result     := Validate_LPN(l_lpn);

  IF ( l_result = INV_Validate.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_outermost_lpn_id || ' is an invalid lpn id', G_ERROR);
    END IF;
    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LPN');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '300';
  -- Validate if LPN is valid for this transaction
  l_result := WMS_CONTAINER_PVT.Validate_LPN (
    p_organization_id => p_organization_id
  , p_lpn_id          => p_outermost_lpn_id
  , p_validation_type => WMS_CONTAINER_PVT.G_NO_ONHAND_EXISTS );

  IF ( l_result = WMS_CONTAINER_PVT.F ) THEN
    IF ( l_debug = 1 ) THEN
      mdebug(p_outermost_lpn_id || ' cannot initialize LPN', G_ERROR);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_progress := '400';
  WMS_CONTAINER_PVT.Initialize_LPN (
    p_api_version      => p_api_version
  , p_init_msg_list    => p_init_msg_list
  , p_commit           => p_commit
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  , p_organization_id  => p_organization_id
  , p_outermost_lpn_id => p_outermost_lpn_id );

  IF ( x_return_status <> fnd_api.g_ret_sts_success ) THEN
    IF ( x_return_status = fnd_api.g_ret_sts_error ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := fnd_api.g_ret_sts_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      FOR i in 1..x_msg_count LOOP
        l_msgdata := substr(l_msgdata||' | '||substr(fnd_msg_pub.get(x_msg_count-i+1, 'F'), 0, 200),1,2000);
      END LOOP;
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), 1);
      mdebug('msg: '||l_msgdata, 1);
    END IF;
  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    IF (l_debug = 1) THEN
      mdebug(l_api_name ||' Error progress='||l_progress||' SQL error: '|| SQLERRM(SQLCODE), 1);
    END IF;
END Initialize_LPN;

PROCEDURE validate_lpn (  p_lpn_id               IN          NUMBER
                           , p_unpack_inner_lpns    IN          VARCHAR2
                           , x_msg_count            OUT NOCOPY  NUMBER
                           , x_msg_data             OUT NOCOPY  VARCHAR2
                           , x_return_status        OUT NOCOPY  VARCHAR2
   )
   IS
      l_valid                NUMBER;
      l_lpn_context          NUMBER;
      l_organization_id      NUMBER;
      l_invalid_lpn_context  EXCEPTION;
      l_lpn_not_found        EXCEPTION;
      l_transactions_pending EXCEPTION;
      l_table_name           VARCHAR2(100);
      l_debug                NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

      CURSOR all_child_wlpns
      IS SELECT lpn_id
           FROM wms_license_plate_numbers
          START WITH lpn_id = p_lpn_id
        CONNECT BY parent_lpn_id = PRIOR lpn_id;

   BEGIN

      IF l_debug = 1 THEN
         mdebug('Inside Validate LPN');
      END IF;

      l_valid := 0;

      FOR all_child_wlpn_rec IN all_child_wlpns LOOP

         BEGIN

            SELECT lpn_context
                 , organization_id
              INTO l_lpn_context
                 , l_organization_id
              FROM wms_license_plate_numbers
             WHERE lpn_id = p_lpn_id;

            IF l_lpn_context <> 4 THEN
               IF l_debug = 1 THEN
                  mdebug('LPN : '|| p_lpn_id ||' has context : '|| l_lpn_context ||' only LPNs with context 4 can be reused');
               END IF;
               RAISE l_invalid_lpn_context;
            END IF;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF l_debug = 1 THEN
               mdebug('LPN : '|| p_lpn_id ||' does not exist');
            END IF;
            RAISE l_lpn_not_found;
         END;

         SELECT COUNT(1)
           INTO l_valid
           FROM mtl_material_transactions_temp
          WHERE organization_id = l_organization_id
            AND ( lpn_id = p_lpn_id
               OR transfer_lpn_id = p_lpn_id
               OR content_lpn_id = p_lpn_id
               OR allocated_lpn_id = p_lpn_id
               OR cartonization_id = p_lpn_id
               );

         IF l_valid > 0 THEN
            IF l_debug = 1 THEN
               mdebug('Pending MMTT transactions exists against this LPN : '||p_lpn_id||', cannot reuse');
            END IF;
            l_table_name := 'MTL_MATERIAL_TRANSACTIONS_TEMP';
            RAISE l_transactions_pending;
         END IF;

         SELECT COUNT(1)
           INTO l_valid
           FROM mtl_transactions_interface
          WHERE organization_id = l_organization_id
            AND ( lpn_id = p_lpn_id
               OR transfer_lpn_id = p_lpn_id
               OR content_lpn_id = p_lpn_id
               );

         IF l_valid > 0 THEN
            IF l_debug = 1 THEN
               mdebug('Pending MTI transactions exists against this LPN : '||p_lpn_id||', cannot reuse');
            END IF;
            l_table_name := 'MTL_TRANSACTIONS_INTERFACE';
            RAISE l_transactions_pending;
         END IF;

         SELECT COUNT(1)
           INTO l_valid
           FROM mtl_onhand_quantities_detail
          WHERE organization_id = l_organization_id
            AND lpn_id = p_lpn_id;

         IF l_valid > 0 THEN
            IF l_debug = 1 THEN
               mdebug('LPN : '||p_lpn_id||' is currently present in MOQD, cannot reuse');
            END IF;
            l_table_name := 'MTL_ONHAND_QUANTITIES_DETAIL';
            RAISE l_transactions_pending;
         END IF;

         SELECT COUNT(1)
           INTO l_valid
           FROM mtl_txn_request_lines
          WHERE organization_id = l_organization_id
            AND lpn_id = p_lpn_id
            AND line_status = 7;

         IF l_valid > 0 THEN
            IF l_debug = 1 THEN
               mdebug('LPN : '||p_lpn_id||' has an open move order line against it, cannot reuse');
            END IF;
            l_table_name := 'MTL_TXN_REQUEST_LINES';
            RAISE l_transactions_pending;
         END IF;

         SELECT COUNT(1)
           INTO l_valid
           FROM mtl_reservations
          WHERE organization_id = l_organization_id
            AND lpn_id = p_lpn_id;

         IF l_valid > 0 THEN
            IF l_debug = 1 THEN
               mdebug('LPN : '||p_lpn_id||' has existing reservations against it, cannot reuse');
            END IF;
            l_table_name := 'MTL_RESERVATIONS';
            RAISE l_transactions_pending;
         END IF;

         SELECT COUNT(1)
           INTO l_valid
           FROM mtl_serial_numbers
          WHERE lpn_id = p_lpn_id
            AND current_organization_id = l_organization_id
            AND current_status <> 4;

         IF l_valid > 0 THEN
            IF l_debug = 1 THEN
               mdebug('LPN : '||p_lpn_id||' has serials which are not shipped out, cannot reuse');
            END IF;
            l_table_name := 'MTL_SERIAL_NUMBERS';
            RAISE l_transactions_pending;
         END IF;

         SELECT COUNT(1)
           INTO l_valid
           FROM rcv_transactions_interface
          WHERE lpn_id = p_lpn_id
             OR transfer_lpn_id = p_lpn_id;

         IF l_valid > 0 THEN
            IF l_debug = 1 THEN
               mdebug('LPN : '||p_lpn_id||' has unprocessed records in rcv_transactions_interface table, cannot reuse');
            END IF;
            l_table_name := 'RCV_TRANSACTIONS_INTERFACE';
            RAISE l_transactions_pending;
         END IF;

         SELECT COUNT(1)
           INTO l_valid
           FROM wsh_delivery_details
          WHERE organization_id = l_organization_id
            AND lpn_id = p_lpn_id
            AND released_status = 'X';

         IF l_valid > 0 THEN
            IF l_debug = 1 THEN
               mdebug('LPN : '||p_lpn_id||' has unprocessed records in wsh_delivery_details table, cannot reuse');
            END IF;
            l_table_name := 'WSH_DELIVERY_DETAILS';
            RAISE l_transactions_pending;
         END IF;

         IF p_unpack_inner_lpns = 'N' THEN
            IF l_debug = 1 THEN
               mdebug('p_unpack_inner_lpns = N therefore only validating lpn : '||p_lpn_id);
            END IF;
            EXIT;
         END IF;

      END LOOP;

      x_return_status := 'S';

   EXCEPTION
      WHEN l_transactions_pending THEN
         FND_MESSAGE.SET_NAME('WMS', 'WMS_PENDING_TRX_RECORDS');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         x_return_status := 'E';
      WHEN l_invalid_lpn_context THEN
         FND_MESSAGE.SET_NAME('WMS', 'WMS_WRONG_TO_LPN_CONTEXT');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         x_return_status := 'E';
      WHEN l_lpn_not_found THEN
         FND_MESSAGE.SET_NAME('WMS', 'WMS_LPN_NOTFOUND');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         x_return_status := 'E';
      WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('WMS', 'WMS_UNEXPECTED_ERROR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         x_return_status := 'E';
   END validate_lpn;



   PROCEDURE REUSE_LPNS (
                    p_api_version              IN         NUMBER
                  , p_init_msg_list            IN         VARCHAR2 := fnd_api.g_false
                  , p_commit                   IN         VARCHAR2 := fnd_api.g_false
                  , p_validation_level         IN         NUMBER   := fnd_api.g_valid_level_full
                  , x_return_status            OUT NOCOPY VARCHAR2
                  , x_msg_count                OUT NOCOPY NUMBER
                  , x_msg_data                 OUT NOCOPY VARCHAR2
                  , p_lpn_id                   IN         NUMBER
                  , p_clear_attributes         IN         VARCHAR2
                  , p_new_org_id               IN         NUMBER
                  , p_unpack_inner_lpns        IN         VARCHAR2
                  , p_clear_containter_item_id IN         VARCHAR2
                  )
   IS

      l_invalid_org          EXCEPTION;
      l_invalid_lpn          EXCEPTION;
      l_wlpn_row_id          ROWID;
      l_valid                NUMBER;
      l_organization_id      NUMBER;
      l_container_item_id    NUMBER;
      l_parent_lpn_id        NUMBER;
      l_lpn_context          NUMBER;
      l_api_name             VARCHAR2(100) := 'REUSE_LPNS';
      l_outermost_lpn_id     NUMBER;
      l_outermost_lpn_name   WMS_LICENSE_PLATE_NUMBERS.LICENSE_PLATE_NUMBER%TYPE;
      l_lpn_name             WMS_LICENSE_PLATE_NUMBERS.LICENSE_PLATE_NUMBER%TYPE;
      l_debug                NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      l_api_version          CONSTANT NUMBER := 1.0;

      CURSOR immediate_child_wlpns
      IS SELECT lpn_id
           FROM wms_license_plate_numbers
          WHERE parent_lpn_id = p_lpn_id;

      CURSOR all_child_wlpns (p_lpn_id IN NUMBER)
      IS SELECT lpn_id
           FROM wms_license_plate_numbers
          WHERE lpn_id <> p_lpn_id
          START WITH lpn_id = p_lpn_id
        CONNECT BY parent_lpn_id = PRIOR lpn_id;

      CURSOR all_child_wlpns1
      IS SELECT lpn_id
           FROM wms_license_plate_numbers
          START WITH lpn_id = p_lpn_id
        CONNECT BY parent_lpn_id = PRIOR lpn_id;

   BEGIN


      IF l_debug = 1 THEN
         mdebug('Inside REUSE_LPNS procedure will following parameters :');
         mdebug('p_api_version : '|| p_api_version);
         mdebug('p_init_msg_list :'|| p_init_msg_list);
         mdebug('p_commit :'|| p_commit);
         mdebug('p_validation_level :'|| p_validation_level);
         mdebug('p_lpn_id : '||p_lpn_id);
         mdebug('p_clear_attributes : '||p_clear_attributes);
         mdebug('p_new_org_id : '|| p_new_org_id);
         mdebug('p_unpack_inner_lpns : '||p_unpack_inner_lpns);
         mdebug('p_clear_containter_item_id : '||p_clear_containter_item_id);
      END IF;

      IF p_init_msg_list ='Y' THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT FND_API.Compatible_API_Call( l_api_version
                                        , p_api_version
                                        , l_api_name
                                        , G_PKG_NAME) THEN

         IF l_debug = 1 THEN
            mdebug('API Version not compatible');
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF p_new_org_id IS NOT NULL THEN
         SELECT count(1)
           INTO l_valid
           FROM mtl_parameters
          WHERE organization_id = p_new_org_id
            AND wms_enabled_flag = 'Y';
      END IF;

      IF l_valid = 0 THEN
         IF l_debug = 1 THEN
            mdebug('Organization : '|| p_new_org_id ||' does not exist or its not warehouse enabled');
         END IF;
         RAISE l_invalid_org;
      END IF;

      validate_lpn (
                     p_lpn_id               =>  p_lpn_id
                   , p_unpack_inner_lpns    =>  p_unpack_inner_lpns
                   , x_return_status        =>  x_return_status
                   , x_msg_count            =>  x_msg_count
                   , x_msg_data             =>  x_msg_data
                   );

      IF NVL(x_return_status,'E') = 'E' THEN
         IF l_debug = 1 THEN
            mdebug('Validate LPN returned error');
         END IF;
         RAISE l_invalid_lpn;
      END IF;

      SELECT organization_id
           , lpn_context
           , ROWID
           , license_plate_number
           , parent_lpn_id
           , outermost_lpn_id
           , inventory_item_id
        INTO l_organization_id
           , l_lpn_context
           , l_wlpn_row_id
           , l_lpn_name
           , l_parent_lpn_id
           , l_outermost_lpn_id
           , l_container_item_id
        FROM wms_license_plate_numbers
       WHERE lpn_id = p_lpn_id;

      SAVEPOINT REUSE_LPN_SP;

      -- To see if it is the outermost lpn id

      IF l_outermost_lpn_id = p_lpn_id THEN
         l_outermost_lpn_name := l_lpn_name;
      ELSE
         SELECT license_plate_number
           INTO l_outermost_lpn_name
           FROM wms_license_plate_numbers
          WHERE lpn_id = l_outermost_lpn_id;
      END IF;

      IF l_debug = 1 THEN
         mdebug('Outer most lpn name : '|| l_outermost_lpn_name);
      END IF;

      IF p_unpack_inner_lpns = 'N' THEN

         INSERT INTO wms_lpn_histories (
              LPN_HISTORY_ID      -- Sequence
          ,   SECONDARY_QUANTITY  -- wlc.parent_lpn_id
          ,   SECONDARY_UOM_CODE  --wlc.secondary_uom_code
          ,   CALLER
          ,   SOURCE_TRANSACTION_ID
          ,   TO_SERIAL_NUMBER
          ,   SOURCE_TYPE_ID      -- wlpn.source_type_id
          ,   SOURCE_HEADER_ID    -- wlpn.source_header_id
          ,   SOURCE_LINE_ID      -- wlpn.source_line_id
          ,   SOURCE_LINE_DETAIL_ID  --wlpn.source_line_detail_id
          ,   SOURCE_NAME            --wlpn.source_name
          ,   PARENT_LPN_ID    -- wlc.parent_lpn_id
          ,   PARENT_LICENSE_PLATE_NUMBER  --wlpn.license_plate_number
          ,   LPN_ID
          ,   LICENSE_PLATE_NUMBER
          ,   INVENTORY_ITEM_ID   -- wlc.inventory_item_id
          ,   ITEM_DESCRIPTION    -- wlc.item_description
          ,   REVISION            -- wlc.revision
          ,   LOT_NUMBER          -- wlc.lot_number
          ,   SERIAL_NUMBER       -- msn.serial_number
          ,   QUANTITY            -- Need to derive
          ,   UOM_CODE            -- wlc.uom_code
          ,   ORGANIZATION_ID     -- wlpn.organization_id
          ,   SUBINVENTORY_CODE   -- wlpn.subinventory_code
          ,   LOCATOR_ID          -- wlpn.locator_id
          ,   STATUS_ID           -- wlpn.status_id
          --,   LPN_STATE           -- wlpn.lpn_state  --Commented for Bug#7828840
          ,   SEALED_STATUS       -- wlpn.sealed_status
          ,   OPERATION_MODE      -- Need to derive PACK or UNPACK
          ,   LAST_UPDATE_DATE    -- SYSDATE
          ,   LAST_UPDATED_BY     -- FND_GLOBAL.USER_ID
          ,   CREATION_DATE       -- SYSDATE
          ,   CREATED_BY
          ,   LAST_UPDATE_LOGIN
          ,   REQUEST_ID
          ,   PROGRAM_APPLICATION_ID
          ,   PROGRAM_ID
          ,   PROGRAM_UPDATE_DATE  -- SYSDATE
          ,   ATTRIBUTE_CATEGORY
          ,   ATTRIBUTE1
          ,   ATTRIBUTE2
          ,   ATTRIBUTE3
          ,   ATTRIBUTE4
          ,   ATTRIBUTE5
          ,   ATTRIBUTE6
          ,   ATTRIBUTE7
          ,   ATTRIBUTE8
          ,   ATTRIBUTE9
          ,   ATTRIBUTE10
          ,   ATTRIBUTE11
          ,   ATTRIBUTE12
          ,   ATTRIBUTE13
          ,   ATTRIBUTE14
          ,   ATTRIBUTE15
          ,   COST_GROUP_ID        --wlc.cost_group_id
          ,   LPN_CONTEXT          --wlpn.lpn_context
          ,   LPN_REUSABILITY      --wlpn.lpn_reusability
          ,   OUTERMOST_LPN_ID     --wlpn.outermost_lpn_id
          ,   OUTERMOST_LICENSE_PLATE_NUMBER  -- Need to derive
          ,   HOMOGENEOUS_CONTAINER  --wlpn.homogeneous_container
          ) SELECT
              wms_lpn_histories_s.NEXTVAL -- LPN_HISTORY_ID
          ,   wlc.quantity                -- SECONDARY_QUANTITY
          ,   wlc.secondary_uom_code      -- SECONDARY_UOM_CODE
          ,   NULL                        -- CALLER
          ,   NULL                        -- SOURCE_TRANSACTION_ID
          ,   msn.serial_number           -- TO_SERIAL_NUMBER
          ,   wlpn1.source_type_id         -- SOURCE_TYPE_ID
          ,   wlpn1.source_header_id       -- SOURCE_HEADER_ID
          ,   wlpn1.source_line_id         -- SOURCE_LINE_ID
          ,   wlpn1.source_line_detail_id  -- SOURCE_LINE_DETAIL_ID
          ,   wlpn1.source_name            -- SOURCE_NAME
          ,   wlpn1.lpn_id                 -- PARENT_LPN_ID
          ,   wlpn1.license_plate_number   -- PARENT_LICENSE_PLATE_NUMBER
          ,   wlpn2.lpn_id                 -- LPN_ID
          ,   wlpn2.license_plate_number   -- LICENSE_PLATE_NUMBER
          ,   wlc.inventory_item_id        -- INVENTORY_ITEM_ID
          ,   wlc.item_description         -- ITEM_DESCRIPTION
          ,   wlc.revision                 -- REVISION
          ,   wlc.lot_number               -- LOT_NUMBER
          ,   msn.serial_number            -- SERIAL_NUMBER
          ,   NVL2(msn.serial_number, 1,wlc.quantity) --QUANTITY
          ,   wlc.uom_code                 -- UOM_CODE
          ,   wlpn1.organization_id        -- ORGANIZATION_ID
          ,   wlpn1.subinventory_code       -- SUBINVENTORY_CODE
          ,   wlpn1.locator_id              -- LOCATOR_ID
          ,   wlpn1.status_id               -- STATUS_ID
          --,   wlpn1.lpn_state                -- LPN_STATE  --Commented for Bug#7828840
          ,   wlpn1.sealed_status            -- SEALED_STATUS
          ,   2                             -- OPERATION_MODE
          ,   SYSDATE                       -- LAST_UPDATE_DATE
          ,   FND_GLOBAL.USER_ID            -- LAST_UPDATED_BY
          ,   SYSDATE                       -- CREATION_DATE
          ,   FND_GLOBAL.USER_ID            -- CREATED_BY
          ,   FND_GLOBAL.USER_ID            -- LAST_UPDATE_LOGIN
          ,   NULL                          -- REQUEST_ID
          ,   NULL                          -- PROGRAM_APPLICATION_ID
          ,   NULL                          -- PROGRAM_ID
          ,   NULL                          -- PROGRAM_UPDATE_DATE
          ,   wlpn1.attribute_category
          ,   wlpn1.ATTRIBUTE1
          ,   wlpn1.ATTRIBUTE2
          ,   wlpn1.ATTRIBUTE3
          ,   wlpn1.ATTRIBUTE4
          ,   wlpn1.ATTRIBUTE5
          ,   wlpn1.ATTRIBUTE6
          ,   wlpn1.ATTRIBUTE7
          ,   wlpn1.ATTRIBUTE8
          ,   wlpn1.ATTRIBUTE9
          ,   wlpn1.ATTRIBUTE10
          ,   wlpn1.ATTRIBUTE11
          ,   wlpn1.ATTRIBUTE12
          ,   wlpn1.ATTRIBUTE13
          ,   wlpn1.ATTRIBUTE14
          ,   wlpn1.ATTRIBUTE15
          ,   wlc.cost_group_id                   -- COST_GROUP_ID
          ,   wlpn1.lpn_context                   -- LPN_CONTEXT
          ,   wlpn1.lpn_reusability               -- LPN_REUSABILITY
          ,   wlpn1.lpn_id                        -- OUTERMOST_LPN_ID
          ,   l_outermost_lpn_name                -- OUTERMOST_LICENSE_PLATE_NUMBER
          ,   wlpn1.homogeneous_container         -- HOMOGENEOUS_CONTAINER
          FROM wms_license_plate_numbers wlpn1
             , wms_license_plate_numbers wlpn2
             , wms_lpn_contents wlc
             , mtl_serial_numbers msn
         WHERE wlpn1.lpn_id = wlc.parent_lpn_id(+)
         AND wlpn1.lpn_id = msn.lpn_id(+)
         AND wlpn1.lpn_id = wlpn2.parent_lpn_id(+)
         AND wlpn1.lpn_id = p_lpn_id;

         IF l_debug = 1 THEN
            mdebug('Inserted wms_lpn_histories rows for lpn : '|| p_lpn_id);
         END IF;

         DELETE FROM wms_lpn_contents
         WHERE parent_lpn_id = p_lpn_id;

         IF p_clear_attributes = 'Y' THEN
            UPDATE wms_license_plate_numbers
               SET  ATTRIBUTE1  = NULL
                  , ATTRIBUTE2  = NULL
                  , ATTRIBUTE3  = NULL
                  , ATTRIBUTE4  = NULL
                  , ATTRIBUTE5  = NULL
                  , ATTRIBUTE6  = NULL
                  , ATTRIBUTE7  = NULL
                  , ATTRIBUTE8  = NULL
                  , ATTRIBUTE9  = NULL
                  , ATTRIBUTE10 = NULL
                  , ATTRIBUTE11 = NULL
                  , ATTRIBUTE12 = NULL
                  , ATTRIBUTE13 = NULL
                  , ATTRIBUTE14 = NULL
                  , ATTRIBUTE15 = NULL
                  , ATTRIBUTE_CATEGORY = NULL
             WHERE ROWID = l_wlpn_row_id;
         END IF;

         IF l_parent_lpn_id IS NULL THEN -- This parameter LPN is the outermost_lpn

            IF l_debug = 1 THEN
               mdebug('LPN : '|| p_lpn_id ||' is the outermost LPN');
            END IF;

            FOR immediate_child_wlpn_rec IN immediate_child_wlpns LOOP

               IF l_debug = 1 THEN
                  mdebug('Updating its immediate chile LPNs : '|| immediate_child_wlpn_rec.lpn_id);
               END IF;

               UPDATE wms_license_plate_numbers
                  SET parent_lpn_id = NULL
                    , outermost_lpn_id = immediate_child_wlpn_rec.lpn_id
                WHERE lpn_id = immediate_child_wlpn_rec.lpn_id;

               FOR all_child_wlpn_rec IN all_child_wlpns (immediate_child_wlpn_rec.lpn_id) LOOP

                  IF l_debug = 1 THEN
                     mdebug('Updating all inner lpns of LPN : '|| immediate_child_wlpn_rec.lpn_id);
                  END IF;

                  UPDATE wms_license_plate_numbers
                     SET outermost_lpn_id = immediate_child_wlpn_rec.lpn_id
                   WHERE lpn_id = all_child_wlpn_rec.lpn_id;

               END LOOP;
            END LOOP;
         ELSE
            FOR immediate_child_wlpn_rec IN immediate_child_wlpns LOOP
                UPDATE wms_license_plate_numbers
                  SET parent_lpn_id = l_parent_lpn_id
                WHERE lpn_id = immediate_child_wlpn_rec.lpn_id;
            END LOOP;
         END IF;

         IF p_new_org_id IS NOT NULL THEN
            UPDATE wms_license_plate_numbers
               SET lpn_context = 5
                 , subinventory_code = NULL
                 , locator_id = NULL
                 , parent_lpn_id = NULL
                 , outermost_lpn_id = p_lpn_id
                 , organization_id = p_new_org_id
             WHERE ROWID = l_wlpn_row_id;
         ELSE
            UPDATE wms_license_plate_numbers
            SET lpn_context = 5
                , subinventory_code = NULL
                , locator_id = NULL
                , parent_lpn_id = NULL
                , outermost_lpn_id = p_lpn_id
             WHERE ROWID = l_wlpn_row_id;
         END IF;

         UPDATE mtl_serial_numbers
         SET lpn_id = NULL
         WHERE lpn_id = p_lpn_id
         AND current_organization_id = l_organization_id;

         UPDATE wms_license_plate_numbers
         SET content_volume = NULL
             , content_volume_uom_code = NULL
         WHERE ROWID = l_wlpn_row_id;

	      IF l_container_item_id IS NULL
	      OR p_clear_containter_item_id = 'Y' THEN
            UPDATE wms_license_plate_numbers
               SET inventory_item_id = NULL
                 , gross_weight = NULL
                 , gross_weight_uom_code = NULL
                 , tare_weight = NULL
                 , tare_weight_uom_code = NULL
                 , container_volume = NULL
                 , container_volume_uom = NULL
             WHERE ROWID = l_wlpn_row_id;

	      ELSIF p_clear_containter_item_id = 'N'
	      AND l_container_item_id IS NOT NULL THEN
            IF ( NOT inv_cache.set_item_rec( p_organization_id => p_new_org_id
                                           , p_item_id       => l_container_item_id ) ) THEN
               IF l_debug = 1 THEN
                  mdebug('Error calling inv_cache.set_item_rec');
               END IF;
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;

	        	UPDATE wms_license_plate_numbers
               SET gross_weight = inv_cache.item_rec.unit_weight
                 , gross_weight_uom_code = inv_cache.item_rec.weight_uom_code
                 , tare_weight = inv_cache.item_rec.unit_weight
                 , tare_weight_uom_code = inv_cache.item_rec.weight_uom_code
                 , container_volume = inv_cache.item_rec.unit_volume
                 , container_volume_uom = inv_cache.item_rec.volume_uom_code
             WHERE ROWID = l_wlpn_row_id;
	      END IF;

      ELSIF p_unpack_inner_lpns = 'Y' THEN

         FOR all_child_wlpn_rec IN all_child_wlpns1 LOOP

            SELECT license_plate_number
              INTO l_outermost_lpn_name
              FROM wms_license_plate_numbers
             WHERE lpn_id = (SELECT outermost_lpn_id
                               FROM wms_license_plate_numbers
                              WHERE lpn_id = all_child_wlpn_rec.lpn_id);


            INSERT INTO wms_lpn_histories (
                 LPN_HISTORY_ID      -- Sequence
             ,   SECONDARY_QUANTITY  -- wlc.parent_lpn_id
             ,   SECONDARY_UOM_CODE  --wlc.secondary_uom_code
             ,   CALLER
             ,   SOURCE_TRANSACTION_ID
             ,   TO_SERIAL_NUMBER
             ,   SOURCE_TYPE_ID      -- wlpn.source_type_id
             ,   SOURCE_HEADER_ID    -- wlpn.source_header_id
             ,   SOURCE_LINE_ID      -- wlpn.source_line_id
             ,   SOURCE_LINE_DETAIL_ID  --wlpn.source_line_detail_id
             ,   SOURCE_NAME            --wlpn.source_name
             ,   PARENT_LPN_ID    -- wlc.parent_lpn_id
             ,   PARENT_LICENSE_PLATE_NUMBER  --wlpn.license_plate_number
             ,   LPN_ID
             ,   LICENSE_PLATE_NUMBER
             ,   INVENTORY_ITEM_ID   -- wlc.inventory_item_id
             ,   ITEM_DESCRIPTION    -- wlc.item_description
             ,   REVISION            -- wlc.revision
             ,   LOT_NUMBER          -- wlc.lot_number
             ,   SERIAL_NUMBER       -- msn.serial_number
             ,   QUANTITY            -- Need to derive
             ,   UOM_CODE            -- wlc.uom_code
             ,   ORGANIZATION_ID     -- wlpn.organization_id
             ,   SUBINVENTORY_CODE   -- wlpn.subinventory_code
             ,   LOCATOR_ID          -- wlpn.locator_id
             ,   STATUS_ID           -- wlpn.status_id
             --,   LPN_STATE           -- wlpn.lpn_state  --Commented for Bug#7828840
             ,   SEALED_STATUS       -- wlpn.sealed_status
             ,   OPERATION_MODE      -- Need to derive PACK or UNPACK
             ,   LAST_UPDATE_DATE    -- SYSDATE
             ,   LAST_UPDATED_BY     -- FND_GLOBAL.USER_ID
             ,   CREATION_DATE       -- SYSDATE
             ,   CREATED_BY
             ,   LAST_UPDATE_LOGIN
             ,   REQUEST_ID
             ,   PROGRAM_APPLICATION_ID
             ,   PROGRAM_ID
             ,   PROGRAM_UPDATE_DATE  -- SYSDATE
             ,   ATTRIBUTE_CATEGORY
             ,   ATTRIBUTE1
             ,   ATTRIBUTE2
             ,   ATTRIBUTE3
             ,   ATTRIBUTE4
             ,   ATTRIBUTE5
             ,   ATTRIBUTE6
             ,   ATTRIBUTE7
             ,   ATTRIBUTE8
             ,   ATTRIBUTE9
             ,   ATTRIBUTE10
             ,   ATTRIBUTE11
             ,   ATTRIBUTE12
             ,   ATTRIBUTE13
             ,   ATTRIBUTE14
             ,   ATTRIBUTE15
             ,   COST_GROUP_ID        --wlc.cost_group_id
             ,   LPN_CONTEXT          --wlpn.lpn_context
             ,   LPN_REUSABILITY      --wlpn.lpn_reusability
             ,   OUTERMOST_LPN_ID     --wlpn.outermost_lpn_id
             ,   OUTERMOST_LICENSE_PLATE_NUMBER  -- Need to derive
             ,   HOMOGENEOUS_CONTAINER  --wlpn.homogeneous_container
             ) SELECT
                 wms_lpn_histories_s.NEXTVAL -- LPN_HISTORY_ID
             ,   wlc.quantity                -- SECONDARY_QUANTITY
             ,   wlc.secondary_uom_code      -- SECONDARY_UOM_CODE
             ,   NULL                        -- CALLER
             ,   NULL                        -- SOURCE_TRANSACTION_ID
             ,   msn.serial_number           -- TO_SERIAL_NUMBER
             ,   wlpn1.source_type_id         -- SOURCE_TYPE_ID
             ,   wlpn1.source_header_id       -- SOURCE_HEADER_ID
             ,   wlpn1.source_line_id         -- SOURCE_LINE_ID
             ,   wlpn1.source_line_detail_id  -- SOURCE_LINE_DETAIL_ID
             ,   wlpn1.source_name            -- SOURCE_NAME
             ,   wlpn1.lpn_id                 -- PARENT_LPN_ID
             ,   wlpn1.license_plate_number   -- PARENT_LICENSE_PLATE_NUMBER
             ,   wlpn2.lpn_id                 -- LPN_ID
             ,   wlpn2.license_plate_number   -- LICENSE_PLATE_NUMBER
             ,   wlc.inventory_item_id        -- INVENTORY_ITEM_ID
             ,   wlc.item_description         -- ITEM_DESCRIPTION
             ,   wlc.revision                 -- REVISION
             ,   wlc.lot_number               -- LOT_NUMBER
             ,   msn.serial_number            -- SERIAL_NUMBER
             ,   NVL2(msn.serial_number, 1,wlc.quantity) --QUANTITY
             ,   wlc.uom_code                 -- UOM_CODE
             ,   wlpn1.organization_id        -- ORGANIZATION_ID
             ,   wlpn1.subinventory_code       -- SUBINVENTORY_CODE
             ,   wlpn1.locator_id              -- LOCATOR_ID
             ,   wlpn1.status_id               -- STATUS_ID
             --,   wlpn1.lpn_state                -- LPN_STATE  --Commented for Bug#7828840
             ,   wlpn1.sealed_status            -- SEALED_STATUS
             ,   2                             -- OPERATION_MODE
             ,   SYSDATE                       -- LAST_UPDATE_DATE
             ,   FND_GLOBAL.USER_ID            -- LAST_UPDATED_BY
             ,   SYSDATE                       -- CREATION_DATE
             ,   FND_GLOBAL.USER_ID            -- CREATED_BY
             ,   FND_GLOBAL.USER_ID            -- LAST_UPDATE_LOGIN
             ,   NULL                          -- REQUEST_ID
             ,   NULL                          -- PROGRAM_APPLICATION_ID
             ,   NULL                          -- PROGRAM_ID
             ,   NULL                          -- PROGRAM_UPDATE_DATE
             ,   wlpn1.attribute_category
             ,   wlpn1.ATTRIBUTE1
             ,   wlpn1.ATTRIBUTE2
             ,   wlpn1.ATTRIBUTE3
             ,   wlpn1.ATTRIBUTE4
             ,   wlpn1.ATTRIBUTE5
             ,   wlpn1.ATTRIBUTE6
             ,   wlpn1.ATTRIBUTE7
             ,   wlpn1.ATTRIBUTE8
             ,   wlpn1.ATTRIBUTE9
             ,   wlpn1.ATTRIBUTE10
             ,   wlpn1.ATTRIBUTE11
             ,   wlpn1.ATTRIBUTE12
             ,   wlpn1.ATTRIBUTE13
             ,   wlpn1.ATTRIBUTE14
             ,   wlpn1.ATTRIBUTE15
             ,   wlc.cost_group_id                   -- COST_GROUP_ID
             ,   wlpn1.lpn_context                   -- LPN_CONTEXT
             ,   wlpn1.lpn_reusability               -- LPN_REUSABILITY
             ,   wlpn1.lpn_id                        -- OUTERMOST_LPN_ID
             ,   l_outermost_lpn_name                -- OUTERMOST_LICENSE_PLATE_NUMBER
             ,   wlpn1.homogeneous_container         -- HOMOGENEOUS_CONTAINER
             FROM wms_license_plate_numbers wlpn1
                , wms_license_plate_numbers wlpn2
                , wms_lpn_contents wlc
                , mtl_serial_numbers msn
            WHERE wlpn1.lpn_id = wlc.parent_lpn_id(+)
              AND wlpn1.lpn_id = msn.lpn_id(+)
              AND wlpn1.lpn_id = wlpn2.parent_lpn_id(+)
              AND wlpn1.lpn_id = all_child_wlpn_rec.lpn_id;

            DELETE FROM wms_lpn_contents
            WHERE parent_lpn_id = all_child_wlpn_rec.lpn_id;


            IF p_clear_attributes = 'Y' THEN
               UPDATE wms_license_plate_numbers
                  SET ATTRIBUTE1 = NULL
                    , ATTRIBUTE2 = NULL
                    , ATTRIBUTE3 = NULL
                    , ATTRIBUTE4 = NULL
                    , ATTRIBUTE5 = NULL
                    , ATTRIBUTE6 = NULL
                    , ATTRIBUTE7 = NULL
                    , ATTRIBUTE8 = NULL
                    , ATTRIBUTE9 = NULL
                    , ATTRIBUTE10 = NULL
                    , ATTRIBUTE11 = NULL
                    , ATTRIBUTE12 = NULL
                    , ATTRIBUTE13 = NULL
                    , ATTRIBUTE14 = NULL
                    , ATTRIBUTE15 = NULL
                    , ATTRIBUTE_CATEGORY = NULL
                WHERE lpn_id = all_child_wlpn_rec.lpn_id;
            END IF;

            IF p_new_org_id IS NOT NULL THEN
               UPDATE wms_license_plate_numbers
                  SET lpn_context = 5
                    , subinventory_code = NULL
                    , locator_id = NULL
                    , parent_lpn_id = NULL
                    , outermost_lpn_id = all_child_wlpn_rec.lpn_id
                    , organization_id = p_new_org_id
                WHERE lpn_id = all_child_wlpn_rec.lpn_id;
            ELSE
               UPDATE wms_license_plate_numbers
                  SET lpn_context = 5
                    , subinventory_code = NULL
                    , locator_id = NULL
                    , parent_lpn_id = NULL
                    , outermost_lpn_id = all_child_wlpn_rec.lpn_id
                WHERE lpn_id = all_child_wlpn_rec.lpn_id;
            END IF;

            UPDATE mtl_serial_numbers
               SET lpn_id = NULL
             WHERE lpn_id = all_child_wlpn_rec.lpn_id
               AND current_organization_id = l_organization_id;

            UPDATE wms_license_plate_numbers
            SET content_volume = NULL
                , content_volume_uom_code = NULL
            WHERE lpn_id = all_child_wlpn_rec.lpn_id;

            IF l_container_item_id IS NULL
	         OR p_clear_containter_item_id = 'Y' THEN
               UPDATE wms_license_plate_numbers
                  SET inventory_item_id = NULL
                    , gross_weight = NULL
                    , gross_weight_uom_code = NULL
                    , tare_weight = NULL
                    , tare_weight_uom_code = NULL
                    , container_volume = NULL
                    , container_volume_uom = NULL
                WHERE lpn_id = all_child_wlpn_rec.lpn_id;

            ELSIF p_clear_containter_item_id = 'N'
            AND l_container_item_id IS NOT NULL THEN
               IF ( NOT inv_cache.set_item_rec( p_organization_id => p_new_org_id
                                              , p_item_id       => l_container_item_id ) ) THEN
                  IF l_debug = 1 THEN
                     mdebug('Error calling inv_cache.set_item_rec');
                  END IF;
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;

               UPDATE wms_license_plate_numbers
                  SET gross_weight = inv_cache.item_rec.unit_weight
                    , gross_weight_uom_code = inv_cache.item_rec.weight_uom_code
                    , tare_weight = inv_cache.item_rec.unit_weight
                    , tare_weight_uom_code = inv_cache.item_rec.weight_uom_code
                    , container_volume = inv_cache.item_rec.unit_volume
                    , container_volume_uom = inv_cache.item_rec.volume_uom_code
                WHERE lpn_id = all_child_wlpn_rec.lpn_id;
            END IF;

         END LOOP;

      END IF;

      IF p_commit = fnd_api.g_true THEN
         IF l_debug = 1 THEN
            mdebug('p_commit is true, committing the transaction');
         END IF;
         COMMIT;
      END IF;

      x_return_status := 'S';

      IF l_debug = 1 THEN
         mdebug('Returning normally from REUSE_LPNS');
      END IF;

   EXCEPTION

      WHEN l_invalid_org THEN
         FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_ORG');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         x_return_status := 'E';
      WHEN l_invalid_lpn THEN
         x_return_status := 'E';
      WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('WMS', 'WMS_UNEXPECTED_ERROR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
         x_return_status := 'E';
         ROLLBACK TO REUSE_LPN_SP;
  END REUSE_LPNS;
-- End of package
END WMS_CONTAINER_PUB;

/

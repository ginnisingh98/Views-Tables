--------------------------------------------------------
--  DDL for Package INV_RESERVATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_PUB" AUTHID CURRENT_USER AS
/* $Header: INVRSVPS.pls 120.4 2007/12/17 13:23:05 ckrishna ship $ */

------------------------------------------------------------------------------
-- Note
--   APIs in this package conforms to the PLSQL Business Object API Coding
--   Standard.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Please refers to inv_reservation_global package spec for the definitions
-- of mtl_reservation_rec_type, mtl_reservation_rec_type and
-- serial_number_tbl_type
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Procedures and Functions
------------------------------------------------------------------------------
-- Procedure
--   create_reservation
--
-- Description
--   Create a material reservation for an item
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not.
--                              Should be fnd_api.g_false or fnd_api.g_true
--
--   p_rsv_rec                  Contains info to be used to create the
--                              reservation
--
--   p_serial_number            Contains serial numbers to be reserved
--
--   p_partial_reservation_flag If there is not enough quantity, whether or not
--                              to reserve the amount that is available
--                              Should be fnd_api.g_false or fnd_api.g_true
--
--   p_force_reservation_flag   Whether or not to reserve without quantity
--                              check.
--                              Currently the api (public) will always ignore
--                              this flag, and always does quantity check.
--
--   p_validation_flag          Whether or not to reserve without validation.
--                              Currently the api (public) will always ignore
--                              this flag, and always does validation.
--  p_partial_rsv_exists        This parameter was added to be passed in case
--                              a partial reservation already exists.
--                              If passed as true we will query reservations
--                              and update them else new reservations are created.
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if
--                              an unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message
--                              is in this output parameter
--
--   x_serial_number            The serial numbers actually reserved if
--                              succeeded
--
--   x_quantity_reserved        The quantity actual reserved if succeeded
--
--   x_reservation_id           The reservation id for the reservation created
--                              if succeeded
-- Example
--   The following code creates a reservation of item id 149 in org 207
--   for demand source OE, order number 1234567 and line 3, with
--   supply from inventory, subinventory Stores. The item is not
--   under revision, lot or locator control
--
--   DECLARE
--      l_rsv       inv_reservation_global.mtl_reservation_rec_type;
--      l_msg_count NUMBER;
--      l_msg_data  VARCHAR2(240);
--      l_rsv_id    NUMBER;
--      l_dummy_sn  inv_reservation_global.serial_number_tbl_type;
--      l_status    VARCHAR2(1);
--   BEGIN
--      l_rsv.reservation_id               := NULL; -- cannot know
--      l_rsv.requirement_date             := Sysdate+30;
--      l_rsv.organization_id              := 207;
--      l_rsv.inventory_item_id            := 149;

--      l_rsv.demand_source_type_id        :=
--            inv_reservation_global.g_source_type_oe; -- order entry

--      l_rsv.demand_source_name           := NULL;
--      l_rsv.demand_source_header_id      := 1234567; -- oe order number
--      l_rsv.demand_source_line_id        := 3;  -- oe order line number
--      l_rsv.primary_uom_code             := 'Ea';
--      l_rsv.primary_uom_id               := NULL;
--      l_rsv.reservation_uom_code         := NULL;
--      l_rsv.reservation_uom_id           := NULL;
--      l_rsv.reservation_quantity         := NULL;
--      l_rsv.primary_reservation_quantity := 35;
--      l_rsv.autodetail_group_id          := NULL;
--      l_rsv.external_source_code         := NULL;
--      l_rsv.external_source_line_id      := NULL;

--      l_rsv.supply_source_type_id        :=
--            inv_reservation_global.g_source_type_inv;

--      l_rsv.supply_source_header_id      := NULL;
--      l_rsv.supply_source_line_id        := NULL;
--      l_rsv.supply_source_name           := NULL;
--      l_rsv.supply_source_line_detail    := NULL;
--      l_rsv.revision                     := NULL;
--      l_rsv.subinventory_code            := 'Stores';
--      l_rsv.subinventory_id              := NULL;
--      l_rsv.locator_id                   := NULL;
--      l_rsv.lot_number                   := NULL;
--      l_rsv.lot_number_id                := NULL;
--      l_rsv.pick_slip_number             := NULL;
--      l_rsv.lpn_id                       := NULL;
--      l_rsv.attribute_category           := NULL;
--      l_rsv.attribute1                   := NULL;
--      l_rsv.attribute2                   := NULL;
--      l_rsv.attribute3                   := NULL;
--      l_rsv.attribute4                   := NULL;
--      l_rsv.attribute5                   := NULL;
--      l_rsv.attribute6                   := NULL;
--      l_rsv.attribute7                   := NULL;
--      l_rsv.attribute8                   := NULL;
--      l_rsv.attribute9                   := NULL;
--      l_rsv.attribute10                  := NULL;
--      l_rsv.attribute11                  := NULL;
--      l_rsv.attribute12                  := NULL;
--      l_rsv.attribute13                  := NULL;
--      l_rsv.attribute14                  := NULL;
--      l_rsv.attribute15                  := NULL;
--
--      inv_reservation_pub.create_reservation
--        (
--           p_api_version_number        => 1.0
--         , p_init_msg_lst              => fnd_api.g_ture
--         , x_return_status             => l_status
--         , x_msg_count                 => l_msg_count
--         , x_msg_data                  => l_msg_data
--         , p_rsv_rec                   => l_rsv
--         , p_serial_number		 => l_dummy_sn
--         , x_serial_number		 => l_dummy_sn
--         , p_partial_reservation_flag  => fnd_api.g_ture
--         , p_force_reservation_flag    => fnd_api.g_false
--         , p_validation_flag           => fnd_api.g_true
--         , x_quantity_reserved         => l_qty
--         , x_reservation_id	         => l_rsv_id
--         );

--      IF l_status != fnd_api.g_ret_sts_success THEN
--         dbms_output.put_line('Quantity reserved: ' || To_char(l_qty));
--       ELSE
--         IF l_msg_count = 1 THEN
--   	 dbms_output.put_line('Error: '|| l_msg_data);
--          ELSE
--   	 FOR l_index IN 1..l_msg_count LOOP
--   	    fnd_msg_pub.get(l_msg_data);
--   	    dbms_output.put_line('Error: '|| l_msg_data);
--   	 END LOOP;
--         END IF;
--      END IF;
--   END;
--
PROCEDURE create_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec
                 IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number
                 IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number
                 OUT NOCOPY inv_reservation_global.serial_number_tbl_type
   , p_partial_reservation_flag  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag      IN  NUMBER DEFAULT 0
   , x_quantity_reserved         OUT NOCOPY NUMBER
   , x_reservation_id            OUT NOCOPY NUMBER
   , p_partial_rsv_exists        IN  BOOLEAN DEFAULT FALSE
   , p_substitute_flag           IN  BOOLEAN DEFAULT FALSE /* Bug 6044651 */

   );

-- INVCONV BEGIN
-- Create_Reservation OVERLOAD to incorporate secondary quantities
PROCEDURE create_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec
                 IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number
                 IN  inv_reservation_global.serial_number_tbl_type
   , x_serial_number
                 OUT NOCOPY inv_reservation_global.serial_number_tbl_type
   , p_partial_reservation_flag  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_force_reservation_flag    IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag      IN  NUMBER DEFAULT 0
   , x_quantity_reserved         OUT NOCOPY NUMBER
   , x_secondary_quantity_reserved OUT NOCOPY NUMBER
   , x_reservation_id            OUT NOCOPY NUMBER
   , p_partial_rsv_exists        IN  BOOLEAN DEFAULT FALSE
   , p_substitute_flag           IN  BOOLEAN DEFAULT FALSE /* Bug 6044651 */

   );
-- INVCONV END

-- Procedure
--   update_reservation
--
-- Description
--   Update an existing reservation
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not.
--                              Should be fnd_api.g_false or fnd_api.g_true
--
--   p_original_rsv_rec         Contains info for identifying the existing
--                              reservation. If reservation id is passed (not
--                              null and not equals to fnd_api.g_miss_num),
--                              it is used to identify the existing reservation
--                              and all other attributes in this record are
--                              ignored. Otherwise, all attributes with values
--                              not equals to fnd_api.g_miss_xxx are used to
--                              identify the existing reservation.
--
--   p_to_rsv_rec               Contains new values of the attributes to be
--                              updated. If the value of an attribute of the
--                              existing reservation needs update, the new
--                              value of the attribute should be assigned
--                              to the attribute in this record.
--                              For attributes whose value are not to be
--                              updated, the values of these attributes
--                              in this record should be fnd_api.g_miss_xxx.
--                              Notice that attributes of the record type
--                              are initialized to fnd_api.g_miss_xxx.
--                              So if you don't assign a value to an
--                              attribute in this record, it is defaulted
--                              to fnd_api.g_miss_xxx.
--
--   p_original_serial_number   Contains serial numbers reserved by
--                              the existing reservation and to be updated.
--                              (currently not used)
--
--   p_to_serial_number         Contains new serial numbers to be reserved
--                              instead.
--                              (currently not used)
--   p_partial_reservation_flag If there is not enough quantity, whether or not
--                              to reserve the amount that is available
--                              Should be fnd_api.g_false or fnd_api.g_true
--
--
--   p_validation_flag          Whether or not to reserve without validation.
--                              Currently the api (public) will always ignore
--                              this flag, and always does validation.
--
--   p_check_availability       This flag will check for availability before
--                              updating the reservation
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if an
--                              unexpected error occurred
--
--   x_msg_count                Number of error message in the error
--                              message list
--
--   x_msg_data                 If the number of error message in the
--                              error message list is one, the error
--                              message is in this output parameter
--
--
-- This procedure will call the overloaded procedure update_reservation and all
-- the processing for update of the reservation will be done in the overlaoded procedure.
--
--

PROCEDURE update_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_check_availability            IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_over_reservation_flag         IN  NUMBER DEFAULT 0
   );




-- Procedure
--   update_reservation(Overloaded procedure )
--
-- Description
--   Update an existing reservation (to be called from update_reservation)
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not.
--                              Should be fnd_api.g_false or fnd_api.g_true
--
--   p_original_rsv_rec         Contains info for identifying the existing
--                              reservation. If reservation id is passed (not
--                              null and not equals to fnd_api.g_miss_num),
--                              it is used to identify the existing reservation
--                              and all other attributes in this record are
--                              ignored. Otherwise, all attributes with values
--                              not equals to fnd_api.g_miss_xxx are used to
--                              identify the existing reservation.
--
--   p_to_rsv_rec               Contains new values of the attributes to be
--                              updated. If the value of an attribute of the
--                              existing reservation needs update, the new
--                              value of the attribute should be assigned
--                              to the attribute in this record.
--                              For attributes whose value are not to be
--                              updated, the values of these attributes
--                              in this record should be fnd_api.g_miss_xxx.
--                              Notice that attributes of the record type
--                              are initialized to fnd_api.g_miss_xxx.
--                              So if you don't assign a value to an
--                              attribute in this record, it is defaulted
--                              to fnd_api.g_miss_xxx.
--
--   p_original_serial_number   Contains serial numbers reserved by
--                              the existing reservation and to be updated.
--                              (currently not used)
--
--   p_to_serial_number         Contains new serial numbers to be reserved
--                              instead.
--                              (currently not used)
--   p_partial_reservation_flag If there is not enough quantity, whether or not
--                              to reserve the amount that is available
--                              Should be fnd_api.g_false or fnd_api.g_true
--
--   p_check_availability       This flag will check for availability before
--                              updating the reservation
--
--   p_validation_flag          Whether or not to reserve without validation.
--                              Currently the api (public) will always ignore
--                              this flag, and always does validation.
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if an
--                              unexpected error occurred
--
--   x_msg_count                Number of error message in the error
--                              message list
--
--   x_msg_data                 If the number of error message in the
--                              error message list is one, the error
--                              message is in this output parameter
--
--  x_quantity_reserved         This is a out parameter to return the
--                              quantity reserved
--
-- Example
--   The following code update a reservation of item 149 in
--   org 207, demand_source_type oe, demand_source_header_id 1234567
--   , demand_source_line_id 3. The update is to change
--   the primary_reservation_quantity to 30, and requirement
--   date to today + 60 days.
--
--   DECLARE
--      l_rsv_old   inv_reservation_global.mtl_reservation_rec_type;
--      l_rsv_new   inv_reservation_global.mtl_reservation_rec_type;
--      l_msg_count NUMBER;
--      l_msg_data  VARCHAR2(240);
--      l_rsv_id    NUMBER;
--      l_dummy_sn  inv_reservation_global.serial_number_tbl_type;
--      l_status    VARCHAR2(1);
--      l_quantity_reserved NUMBER;
--   BEGIN
--      -- find the existing reservation
--      l_rsv_old.organization_id              := 207;
--      l_rsv_old.inventory_item_id            := 149;
--      l_rsv_old.demand_source_type_id        :=
--            inv_reservation_global.g_source_type_oe; -- order entry
--
--      l_rsv_old.demand_source_header_id      := 1234567; -- oe order number
--      l_rsv_old.demand_source_line_id        := 3;  -- oe order line number
--
--      -- specify the new values
--      l_rsv_new.primary_reservation_quantity := 30;
--      l_rsv_new.requirement_date             := Sysdate+60;
--
--      inv_reservation_pub.update_reservation
--        (
--           p_api_version_number        => 1.0
--         , p_init_msg_lst              => fnd_api.g_ture
--         , x_return_status             => l_status
--         , x_msg_count                 => l_msg_count
--         , x_msg_data                  => l_msg_data
--         , x_quantity_reserved         => l_quantity_reserved
--         , p_original_rsv_rec          => l_rsv_old
--         , p_to_rsv_rec                => l_rsv_new
--         , p_original_serial_number    => l_dummy_sn -- no serial contorl
--         , p_to_serial_number	         => l_dummy_sn -- no serial control
--         , p_validation_flag           => fnd_api.g_true
--         , p_partial_reservation_flag  => fnd_api.g_galse
--         , p_check_availability        => fnd_api.g_galse
--         );
--
--      IF l_status != fnd_api.g_ret_sts_success THEN
--         dbms_output.put_line('Update Done');
--       ELSE
--         IF l_msg_count = 1 THEN
--   	 dbms_output.put_line('Error: '|| l_msg_data);
--          ELSE
--   	 FOR l_index IN 1..l_msg_count LOOP
--   	    fnd_msg_pub.get(l_msg_data);
--   	    dbms_output.put_line('Error: '|| l_msg_data);
--   	 END LOOP;
--         END IF;
--      END IF;
--   END;
--
-- INVCONV
-- Change signature to incorporate secondary_quantity_reserved
PROCEDURE update_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , x_quantity_reserved             OUT NOCOPY NUMBER
   , x_secondary_quantity_reserved   OUT NOCOPY NUMBER
   , p_original_rsv_rec              IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec                    IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number        IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number              IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_partial_reservation_flag      IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_check_availability            IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_over_reservation_flag         IN  NUMBER DEFAULT 0
   );





-- Procedure
--   delete_reservation
--
-- Description
--   Delete an existing reservation
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not. Should be fnd_api.g_false or
--                              fnd_api.g_true
--
--   p_rsv_rec                  Contains info to be used to identify the
--                              existing reservation
--
--   p_serial_number            Contains serial numbers reserved by the
--                              existing reservation
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if an
--                              unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message is
--                              in this output parameter
--
-- Example
--   The following code delete a reservation of item id 149 in org 207
--   for demand source OE, order number 1234567 and line 3, with
--   supply from inventory, subinventory Stores.
--
--   DECLARE
--      l_rsv       inv_reservation_global.mtl_reservation_rec_type;
--      l_msg_count NUMBER;
--      l_msg_data  VARCHAR2(240);
--      l_rsv_id    NUMBER;
--      l_dummy_sn  inv_reservation_global.serial_number_tbl_type;
--      l_status    VARCHAR2(1);
--   BEGIN
--      l_rsv.organization_id              := 207;
--      l_rsv.inventory_item_id            := 149;

--      l_rsv.demand_source_type_id        :=
--            inv_reservation_global.g_source_type_oe; -- order entry

--      l_rsv.demand_source_header_id      := 1234567; -- oe order number
--      l_rsv.demand_source_line_id        := 3;  -- oe order line number
--      l_rsv.supply_source_type_id        :=
--            inv_reservation_global.g_source_type_inv;
--
--      l_rsv.subinventory_code            := 'Stores';

--      inv_reservation_pub.delete_reservation
--        (
--           p_api_version_number        => 1.0
--         , p_init_msg_lst              => fnd_api.g_ture
--         , x_return_status             => l_status
--         , x_msg_count                 => l_msg_count
--         , x_msg_data                  => l_msg_data
--         , p_rsv_rec                   => l_rsv
--         , p_serial_number		 => l_dummy_sn
--         );

--      IF l_status != fnd_api.g_ret_sts_success THEN
--         dbms_output.put_line('reservation deleted');
--       ELSE
--         IF l_msg_count = 1 THEN
--   	 dbms_output.put_line('Error: '|| l_msg_data);
--          ELSE
--   	 FOR l_index IN 1..l_msg_count LOOP
--   	    fnd_msg_pub.get(l_msg_data);
--   	    dbms_output.put_line('Error: '|| l_msg_data);
--   	 END LOOP;
--         END IF;
--      END IF;
--   END;
--
PROCEDURE delete_reservation
  (
     p_api_version_number       IN  NUMBER
   , p_init_msg_lst             IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status            OUT NOCOPY VARCHAR2
   , x_msg_count                OUT NOCOPY NUMBER
   , x_msg_data                 OUT NOCOPY VARCHAR2
   , p_rsv_rec
            IN  inv_reservation_global.mtl_reservation_rec_type
   , p_serial_number
             IN  inv_reservation_global.serial_number_tbl_type
   );
--
-- Procedure
--   relieve_reservation
-- Description
--   Relieve an existing reservation by the specified amount
-- Input Parameters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not. Should be fnd_api.g_false or
--                              fnd_api.g_true
--
--   p_rsv_rec                  Contains info to be used to identify the
--                              existing reservation
--
--   p_primary_relieved_quantity Quantity to relieve in primary uom code
--                               this parameter is required if
--                               p_relieve_all = fnd_api.g_false
--
--   p_relieve_all              If equals to fnd_api.g_true, the api
--                              will relieve all quantity of the reservation
--
--   p_original_serial_number   Contains serial numbers reserved by the
--                              existing reservation
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if an
--                              unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message is
--                              in this output parameter
--
--   x_primary_relieved_quantity quantity relieved by the api in primary uom
--   x_primary_remain_quantity   the remain quantity of the reservation in
--                               primary uom
PROCEDURE relieve_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec
      IN  inv_reservation_global.mtl_reservation_rec_type
   , p_primary_relieved_quantity IN NUMBER
   , p_relieve_all               IN VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_serial_number
      IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_primary_relieved_quantity OUT NOCOPY NUMBER
   , x_primary_remain_quantity   OUT NOCOPY NUMBER
   );

-- INVCONV BEGIN
-- OVERLOAD definition - incorporates secondary quantity
PROCEDURE relieve_reservation
  (
     p_api_version_number        IN  NUMBER
   , p_init_msg_lst              IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status             OUT NOCOPY VARCHAR2
   , x_msg_count                 OUT NOCOPY NUMBER
   , x_msg_data                  OUT NOCOPY VARCHAR2
   , p_rsv_rec
      IN  inv_reservation_global.mtl_reservation_rec_type
   , p_primary_relieved_quantity IN NUMBER
   , p_secondary_relieved_quantity IN NUMBER
   , p_relieve_all               IN VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_serial_number
      IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag           IN  VARCHAR2 DEFAULT fnd_api.g_true
   , x_primary_relieved_quantity OUT NOCOPY NUMBER
   , x_secondary_relieved_quantity OUT NOCOPY NUMBER
   , x_primary_remain_quantity   OUT NOCOPY NUMBER
   , x_secondary_remain_quantity OUT NOCOPY NUMBER
   );

-- INVCONV END

-- Procedure
--   transfer_reservation
-- Description
--   Transfer an existing reservation from one demand source to another
--   or one supply source to another.
-- Note
--   If the target reservation exists, the transfer quantity is added to the
--   quantity of the target reservation, and if the transfer quantity equals
--   to all quantity reserved in the existing reservation (the from side of
--   the transfer), the existing reservation is deleted since we do not
--   keep a reservation of quantity 0. If the target reservation doesn't exist,
--   and not all quantity reserved is transferred, a new reservation is created
--   with the transfer quantity, and the transfer quantity is subtracted from
--   the existing reservation. The following table is a summary of this logic.
--
--   Condition                      Action
--   ----------------------------   -----------------------------------------
--   Transfer_All  To_Side_Exists   From_Side_Reservation To_Side_Reservation
--   ------------  --------------   --------------------- -------------------
--     true            ture         delete                quantity added
--     false           false        quantity subtracted   created
--     true            false        updated               n/a
--     false           ture         quantity subtracted   quantity added
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not. Should be fnd_api.g_false or
--                              fnd_api.g_true
--
--   p_original_rsv_rec         Contains info for identifying the existing
--                              reservation. If reservation id is passed
--                              (not null and not equals to fnd_api.g_miss_num)
--                              , it is used to identify the existing
--                              reservationand all other attributes in this
--                              ignored. Otherwise, all attributes with values
--                              record are not equals to fnd_api.g_miss_xxx
--                              are used to identify the existing reservation.
--
--   p_to_rsv_rec               Contains new values of the attributes for the
--                              target reservation of the transfer. If the
--                              value of an attribute of the existing
--				reservation is different from the target
--				reservation , the new value should be assigned
--                              to the attribute in this record. For attributes
--                              whose value are the same, the values of these
--                              attributes in this record should be
--                              fnd_api.g_miss_xxx.
--                              Notice that attributes of the record type are
--                              initialized to fnd_api.g_miss_xxx. So if you
--                              don't assign a value to an attribute in this
--                              record, it is defaulted to fnd_api.g_miss_xxx.
--                              One important aspect: if you want to transfer
--                              all quantity reserved, you can leave the
--                              attribute primary_reservation_quantity
--                              and reservation_quantity as fnd_api.g_miss_xxx
--                              and the api will transfer all
--                              quantity reserved.
--
--   p_original_serial_number   Contains serial numbers reserved by the
--                              existing reservation and to be transferred.
--                              (currently not used)
--
--   p_to_serial_number         Contains new serial numbers to reserved
--                              instead. (currently not used)
--
--   p_validation_flag          Whether or not to reserve without validation.
--                              Currently the api (public) will always ignore
--                              this flag, and always does validation.
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if an
--                              unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message is
--                              in this output parameter
--
--   x_reservation_id           The reservation id for the target reservation
--                              of the transfer. If the target reseration
--                              does not exists before the transfer, and
--                              all quantity reserved is transferred,
--                              the reservation id of the target reservation
--                              is same as that of the existing
--                              reservation; otherwise, it is different.
-- Example
--   The following code transfer a reservation of item 149 in
--   org 207, demand_source_type oe, demand_source_header_id 1234567
--   , demand_source_line_id 3. It is a partial transfer of quantity of 5
--   and the new subinventory is FGI
--
--   DECLARE
--      l_rsv_old   inv_reservation_global.mtl_reservation_rec_type;
--      l_rsv_new   inv_reservation_global.mtl_reservation_rec_type;
--      l_msg_count NUMBER;
--      l_msg_data  VARCHAR2(240);
--      l_rsv_id    NUMBER;
--      l_dummy_sn  inv_reservation_global.serial_number_tbl_type;
--      l_status    VARCHAR2(1);
--   BEGIN
--      -- find the existing reservation
--      l_rsv_old.organization_id              := 207;
--      l_rsv_old.inventory_item_id            := 149;
--      l_rsv_old.demand_source_type_id        :=
--            inv_reservation_global.g_source_type_oe; -- order entry
--
--      l_rsv_old.demand_source_header_id      := 1234567; -- oe order number
--      l_rsv_old.demand_source_line_id        := 3;  -- oe order line number
--
--      -- specify the new values
--      l_rsv_new.primary_reservation_quantity := 5;
--      l_rsv_new.subinventory_code            := 'FGI';
--
--      inv_reservation_pub.transfer_reservation
--        (
--           p_api_version_number        => 1.0
--         , p_init_msg_lst              => fnd_api.g_ture
--         , x_return_status             => l_status
--         , x_msg_count                 => l_msg_count
--         , x_msg_data                  => l_msg_data
--         , p_original_rsv_rec          => l_rsv_old
--         , p_to_rsv_rec                => l_rsv_new
--         , p_original_serial_number    => l_dummy_sn -- no serial contorl
--         , p_to_serial_number	         => l_dummy_sn -- no serial control
--         , p_validation_flag           => fnd_api.g_true
--         , x_reservation_id            => l_new_rsv_id
--         );
--
--      IF l_status != fnd_api.g_ret_sts_success THEN
--         dbms_output.put_line
--           ('the new reservation id is '|| to_char(l_new_rsv_id));
--       ELSE
--         IF l_msg_count = 1 THEN
--   	 dbms_output.put_line('Error: '|| l_msg_data);
--          ELSE
--   	 FOR l_index IN 1..l_msg_count LOOP
--   	    fnd_msg_pub.get(l_msg_data);
--   	    dbms_output.put_line('Error: '|| l_msg_data);
--   	 END LOOP;
--         END IF;
--      END IF;
--   END;
--
PROCEDURE transfer_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_is_transfer_supply            IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_original_rsv_rec
            IN  inv_reservation_global.mtl_reservation_rec_type
   , p_to_rsv_rec
            IN  inv_reservation_global.mtl_reservation_rec_type
   , p_original_serial_number
            IN  inv_reservation_global.serial_number_tbl_type
   , p_to_serial_number
            IN  inv_reservation_global.serial_number_tbl_type
   , p_validation_flag               IN  VARCHAR2 DEFAULT fnd_api.g_true
   , p_over_reservation_flag         IN  NUMBER DEFAULT 0
   , x_to_reservation_id             OUT NOCOPY NUMBER
   );


-- Procedure
--   query_reservation
-- Description
--   Query reservations based on specified criteria
-- Input Paramters
--   p_api_version_number        API version number (current version is 1.0)
--
--   p_init_msg_lst              Whether initialize the error message list
--                               or not. Should be fnd_api.g_false or
--                               fnd_api.g_true
--
--   p_query_input               Contains info to be used to identify the
--                               reservations.
--   p_lock_records
--                               fnd_api.g_true or fnd_api.g_false (default).
--                               Specify whether to lock matching records
--
--   p_sort_by_req_date
--                               Specify whether to sort the return
--                               records by requirement date
--                               see INVRSVGS.pls for details
--
--   p_cancel_order_mode
--                               If OM(OE) intends to cancel order and
--				 want to query related reservations, they will
--			         be returned in a specific order
--
-- Output Parameters
--   x_return_status             = fnd_api.g_ret_sts_success, if succeeded
--                               = fnd_api.g_ret_sts_exc_error, if an
--                               expected error occurred
--                               = fnd_api.g_ret_sts_unexp_error, if an
--                               unexpected error occurred
--
--   x_msg_count                 Number of error message in the error message
--                               list
--
--   x_msg_data                  If the number of error message in the
--                               error message list is one, the error
--                               message is in this output parameter
--
--   x_mtl_reservation_tbl       Reservations that match the criteria
--
--   x_mtl_reservation_tbl_count The Number of records in x_mtl_reservation_tbl
--
--   x_error_code
--                               This error code is only meaningful
--                               if x_return_status equals
--                               fnd_api.g_ret_sts_error.
--                               see INVRSVGS.pls for error code definition
--
-- Example
--   The following code query all reservations for of item id 149 in org 207.
--
--   DECLARE
--      l_rsv       inv_reservation_global.mtl_reservation_rec_type;
--      l_msg_count NUMBER;
--      l_msg_data  VARCHAR2(240);
--      l_rsv_id    NUMBER;
--      l_status    VARCHAR2(1);
--      l_rsv_array inv_reservation_global.mtl_reservation_tbl_type;
--      l_size      NUMBER;
--   BEGIN
--      l_rsv.organization_id              := 207;
--      l_rsv.inventory_item_id            := 149;
--
--      inv_reservation_pub.query_reservation
--        (
--           p_api_version_number        => 1.0
--         , p_init_msg_lst              => fnd_api.g_ture
--         , x_return_status             => l_status
--         , x_msg_count                 => l_msg_count
--         , x_msg_data                  => l_msg_data
--         , p_query_input               => l_rsv
--         , x_mtl_reservation_tbl	 => l_rsv_array
--         , x_mtl_reservation_tbl_count => l_size
--         );

--      IF l_status != fnd_api.g_ret_sts_success THEN
--         dbms_output.put_line
--            ('number of reservations found: '||to_char(l_size));
--       ELSE
--         IF l_msg_count = 1 THEN
--   	 dbms_output.put_line('Error: '|| l_msg_data);
--          ELSE
--   	 FOR l_index IN 1..l_msg_count LOOP
--   	    fnd_msg_pub.get(l_msg_data);
--   	    dbms_output.put_line('Error: '|| l_msg_data);
--   	 END LOOP;
--         END IF;
--      END IF;
--   END;
--
PROCEDURE query_reservation
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_query_input
           IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date
           IN  NUMBER   DEFAULT inv_reservation_global.g_query_no_sort
   , p_cancel_order_mode
           IN  NUMBER   DEFAULT inv_reservation_global.g_cancel_order_no
   , x_mtl_reservation_tbl
           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   );

/*
** ----------------------------------------------------------------------
** For Order Management(OM) use only. Please read below:
** MUST PASS DEMAND SOURCE HEADER ID AND DEMAND SOURCE LINE ID
** ----------------------------------------------------------------------
** This API has been written exclusively for Order Management, who query
** reservations extensively.
** The generic query reservation API, query_reservation(see signature above)
** builds a dynamic SQL to satisfy all callers as it does not know what the
** search criteria is, at design time.
** The dynamic SQL consumes soft parse time, which reduces performance.
** An excessive use of query_reservation contributes to performance
** degradation because of soft parse times.
** Since we know what OM would always use to query reservations
** - demand source header id and demand source line id, a new API
** with static SQL would be be effective, with reduced performance impact.
** ----------------------------------------------------------------------
** Since OM has been using query_reservation before this, the signature of the
** new API below remains the same to cause minimal impact.
** ----------------------------------------------------------------------
*/

PROCEDURE query_reservation_om_hdr_line
  (
     p_api_version_number            IN  NUMBER
   , p_init_msg_lst                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , x_return_status                 OUT NOCOPY VARCHAR2
   , x_msg_count                     OUT NOCOPY NUMBER
   , x_msg_data                      OUT NOCOPY VARCHAR2
   , p_query_input
           IN  inv_reservation_global.mtl_reservation_rec_type
   , p_lock_records                  IN  VARCHAR2 DEFAULT fnd_api.g_false
   , p_sort_by_req_date
           IN  NUMBER   DEFAULT inv_reservation_global.g_query_no_sort
   , p_cancel_order_mode
           IN  NUMBER   DEFAULT inv_reservation_global.g_cancel_order_no
   , x_mtl_reservation_tbl
           OUT NOCOPY inv_reservation_global.mtl_reservation_tbl_type
   , x_mtl_reservation_tbl_count     OUT NOCOPY NUMBER
   , x_error_code                    OUT NOCOPY NUMBER
   );

END inv_reservation_pub ;

/

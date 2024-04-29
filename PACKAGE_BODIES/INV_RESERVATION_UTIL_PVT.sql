--------------------------------------------------------
--  DDL for Package Body INV_RESERVATION_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATION_UTIL_PVT" AS
/* $Header: INVRSV2B.pls 120.2.12010000.2 2009/05/08 06:52:22 damahaja ship $ */
g_pkg_name CONSTANT VARCHAR2(30) := 'Rsv_Service';
g_next_demand_entry    NUMBER := 1;

PROCEDURE set_file_info
  (
   p_file_name IN VARCHAR2
   ) IS
BEGIN
  /* set file name and directory path */
   -- file location should be changed before released
   fnd_file.put_names
     (
        p_file_name
      , 'RSV_OUTPUT'
      , '/nfs/net/ap111sun/d3/log/dev115'
      );

END set_file_info;

PROCEDURE close_file IS
BEGIN
  fnd_file.close;
END;

PROCEDURE write_to_logfile
  (
     x_return_status    OUT NOCOPY VARCHAR2
   , p_msg_to_append    IN  VARCHAR2
   , p_appl_short_name  IN  VARCHAR2
   , p_file_name        IN  VARCHAR2
   , p_program_name     IN  VARCHAR2
   , p_new_or_append    IN  NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_buff            VARCHAR2(2000);   -- translated message
BEGIN
  /* get translation for mesage code into l_buff */
  FND_MESSAGE.SET_NAME(p_appl_short_name, p_msg_to_append);
  l_buff := FND_MESSAGE.GET;

  /* write to log file the local buffer */
  fnd_file.put(fnd_file.Log, l_buff);
  /* put in 1 (one) carriage return for next write to file */
  fnd_file.new_line(fnd_file.Log, 1);

  x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      -- possible error
      -- utl_file.invalid_path       - file location or name was invalid
      -- utl_file.invalid_mode       - the open_mode string was invalid
      -- utl_file.invalid_filehandle - file handle is invalid
      -- utl_file.invalid_operation  - file is not open for writing/appending
      -- utl_file.write_error        - OS error occured during write operation
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Write_To_Logfile'
              );
      END IF;

END write_to_logfile;

PROCEDURE search_item_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_inventory_item_id       IN  NUMBER
   , p_organization_id         IN  NUMBER
   , x_index                   OUT NOCOPY NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index           NUMBER;
      l_rec             inv_reservation_global.item_record;
BEGIN
   IF inv_reservation_global.g_item_record_cache.EXISTS(p_inventory_item_id) THEN
      IF inv_reservation_global.g_item_record_cache(p_inventory_item_id).organization_id = p_organization_id THEN
         l_index := p_inventory_item_id;
      END IF;
   END IF;

/*
   IF inv_reservation_global.g_item_record_cache.count > 0 THEN
      l_index := inv_reservation_global.g_item_record_cache.first ;
      LOOP
	 IF inv_reservation_global.g_item_record_cache
	   (l_index).inventory_item_id = p_inventory_item_id
	   AND inv_reservation_global.g_item_record_cache
	   (l_index).organization_id = p_organization_id THEN
	    EXIT;
	  ELSE
	    IF l_index = inv_reservation_global.g_item_record_cache.last THEN
	       l_index := NULL;
	       EXIT;
	    END IF;
	    l_index :=
	      inv_reservation_global.g_item_record_cache.next(l_index) ;
	 END IF;
      END LOOP;
   END IF;
*/

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Search_Item_Cache'
              );
      END IF;

END search_item_cache;

PROCEDURE add_item_cache
  (
     x_return_status   OUT NOCOPY VARCHAR2
   , p_item_record     IN  inv_reservation_global.item_record
   , x_index           OUT NOCOPY NUMBER
   ) IS
      l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index          NUMBER;
BEGIN
   --l_index := inv_reservation_global.g_item_record_cache.COUNT+1;
   l_index := p_item_record.inventory_item_id;
   inv_reservation_global.g_item_record_cache(l_index)
     := p_item_record;

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Add_Item_Cache'
              );
      END IF;

END add_item_cache;

PROCEDURE search_organization_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_organization_id         IN  NUMBER
   , x_index                   OUT NOCOPY NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index           NUMBER;
      l_rec             inv_reservation_global.organization_record;
BEGIN
   IF inv_reservation_global.g_organization_record_cache.EXISTS(p_organization_id) THEN
      l_index := p_organization_id;
   END IF;

/*
   IF inv_reservation_global.g_organization_record_cache.count > 0 THEN
      l_index := inv_reservation_global.g_organization_record_cache.first ;
      LOOP
	 IF inv_reservation_global.g_organization_record_cache
	   (l_index).organization_id = p_organization_id THEN
	    EXIT;
	  ELSE
	    IF l_index =
	      inv_reservation_global.g_organization_record_cache.last
	      THEN
	       l_index := NULL;
	       EXIT;
	    END IF;
	    l_index :=
	    inv_reservation_global.g_organization_record_cache.next(l_index) ;
	 END IF;
      END LOOP;
   END IF;
*/

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Search_Organization_Cache'
              );
      END IF;

END search_organization_cache;

PROCEDURE add_organization_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_organization_record     IN  inv_reservation_global.organization_record
   , x_index                   OUT NOCOPY NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index           NUMBER;
BEGIN
   --l_index := inv_reservation_global.g_organization_record_cache.COUNT+1;
   l_index := p_organization_record.organization_id;
   inv_reservation_global.g_organization_record_cache(l_index)
     := p_organization_record;

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Add_Organization_Cache'
              );
      END IF;

END add_organization_cache;

PROCEDURE search_demand_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_demand_source_type_id   IN  NUMBER
   , p_demand_source_header_id IN  NUMBER
   , p_demand_source_line_id   IN  NUMBER
   , p_demand_source_name      IN  VARCHAR2
   , x_index                   OUT NOCOPY NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index           NUMBER;
      l_rec             inv_reservation_global.demand_record;
BEGIN

	 -- Bug 7717612, demand_source_line_id can exceed 2^31 if the max value of the sequence
 	       --    is modified. In such case EXISTS on a plsql table throws NO_DATA_FOUND
 	       --    exception as it is indexed by binary interger.
 	       --    Using MOD(line_id,2^31) to ensure that index always falls
 	       --    in the correct range.

 	 --#BUG 7717612#

-- For increased efficiency if source_line_is is provided then that
-- is used as the index in which to store the demand info hence check that
-- position first. If it is null then use existing check

   IF p_demand_source_line_id IS NOT NULL THEN
      IF inv_reservation_global.g_demand_record_cache.EXISTS(MOD(p_demand_source_line_id,2147483648))THEN
       -- The orginal code allowed any value including demand_source_line_id to be null.
       -- In the case where demand_source_line_id is null the demand record is place
       -- in the first available slot in the table. Hence need to also check if record
       -- returned is actual record required
         IF inv_reservation_global.g_demand_record_cache(MOD(p_demand_source_line_id,2147483648)).demand_source_line_id IS NOT NULL THEN
            l_index := MOD(p_demand_source_line_id,2147483648);
         END IF;
      END IF;
   ELSE -- loop through all
   IF inv_reservation_global.g_demand_record_cache.count > 0 THEN
      l_index := inv_reservation_global.g_demand_record_cache.first ;
      LOOP
	 IF (inv_reservation_global.g_demand_record_cache
	       (l_index).demand_source_type_id IS NULL
		 AND p_demand_source_type_id IS NULL
		   OR inv_reservation_global.g_demand_record_cache
		   (l_index).demand_source_type_id = p_demand_source_type_id)
	   AND (inv_reservation_global.g_demand_record_cache
	       (l_index).demand_source_header_id IS NULL
		 AND p_demand_source_header_id IS NULL
		   OR inv_reservation_global.g_demand_record_cache
		   (l_index).demand_source_header_id
		   = p_demand_source_header_id)
           AND (inv_reservation_global.g_demand_record_cache
	       (l_index).demand_source_line_id IS NULL
		 AND p_demand_source_line_id IS NULL
		   OR inv_reservation_global.g_demand_record_cache
		   (l_index).demand_source_line_id = p_demand_source_line_id)
	   AND (inv_reservation_global.g_demand_record_cache
	       (l_index).demand_source_name IS NULL
		 AND p_demand_source_name IS NULL
		   OR inv_reservation_global.g_demand_record_cache
		   (l_index).demand_source_name = p_demand_source_name)
	   THEN
	    EXIT;
	  ELSE
	    IF l_index =
	      inv_reservation_global.g_demand_record_cache.last THEN
	       l_index := NULL;
	       EXIT;
	    END IF;
	    l_index :=
	      inv_reservation_global.g_demand_record_cache.next(l_index) ;
	 END IF;
      END LOOP;
   END IF;
   END IF;

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Search_Demand_Cache'
              );
      END IF;

END search_demand_cache;

PROCEDURE add_demand_cache
  (
     x_return_status   OUT NOCOPY VARCHAR2
   , p_demand_record   IN  inv_reservation_global.demand_record
   , x_index           OUT NOCOPY NUMBER
   ) IS
      l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index          NUMBER;
BEGIN
   IF p_demand_record.demand_source_line_id IS NOT NULL THEN
    --#BUG7717612#
    --  l_index := p_demand_record.demand_source_line_id;
        l_index := MOD(p_demand_record.demand_source_line_id,2147483648);
    --#BUG7717612#
   ELSE
      -- need to check whether there is a collision and increment accordingly
      LOOP
        IF inv_reservation_global.g_demand_record_cache.EXISTS(g_next_demand_entry)
           THEN g_next_demand_entry := g_next_demand_entry + 1;
        ELSE
           exit; --loop
        END IF;
      END LOOP;
      --l_index := inv_reservation_global.g_demand_record_cache.COUNT+1;
      l_index := g_next_demand_entry;
      g_next_demand_entry := g_next_demand_entry + 1;
   END IF;
   inv_reservation_global.g_demand_record_cache(l_index)
     := p_demand_record;

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Add_Demand_Cache'
              );
      END IF;

END add_demand_cache;

PROCEDURE search_supply_cache
  (
     x_return_status           OUT NOCOPY VARCHAR2
   , p_supply_source_type_id   IN  NUMBER
   , p_supply_source_header_id IN  NUMBER
   , p_supply_source_line_id   IN  NUMBER
   , p_supply_source_name      IN  VARCHAR2
   , x_index                   OUT NOCOPY NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index           NUMBER;
      l_rec             inv_reservation_global.supply_record;
BEGIN

   IF inv_reservation_global.g_supply_record_cache.count > 0 THEN
      l_index := inv_reservation_global.g_supply_record_cache.first ;
      LOOP
	 IF    (inv_reservation_global.g_supply_record_cache
	        (l_index).supply_source_type_id IS NULL
	        AND p_supply_source_type_id IS NULL
		OR inv_reservation_global.g_supply_record_cache
		(l_index).supply_source_type_id = p_supply_source_type_id)
	   AND (inv_reservation_global.g_supply_record_cache
	        (l_index).supply_source_header_id IS NULL
		AND p_supply_source_header_id IS NULL
		OR inv_reservation_global.g_supply_record_cache
		(l_index).supply_source_header_id
		= p_supply_source_header_id)
	   AND (inv_reservation_global.g_supply_record_cache
	        (l_index).supply_source_line_id IS NULL
		AND p_supply_source_line_id IS NULL
		OR inv_reservation_global.g_supply_record_cache
		(l_index).supply_source_line_id = p_supply_source_line_id)
	   AND (inv_reservation_global.g_supply_record_cache
	        (l_index).supply_source_name IS NULL
		AND p_supply_source_name IS NULL
		OR inv_reservation_global.g_supply_record_cache
		(l_index).supply_source_name = p_supply_source_name)
	   THEN
	    EXIT;
	  ELSE
	    IF l_index
	      = inv_reservation_global.g_supply_record_cache.last THEN
	       l_index := NULL;
	       EXIT;
	    END IF;
	    l_index :=
	      inv_reservation_global.g_supply_record_cache.next(l_index) ;
	 END IF;
      END LOOP;
   END IF;

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Search_Supply_Cache'
              );
      END IF;

END search_supply_cache;

PROCEDURE add_supply_cache
  (
     x_return_status   OUT NOCOPY VARCHAR2
   , p_supply_record   IN  inv_reservation_global.supply_record
   , x_index           OUT NOCOPY NUMBER
   ) IS
      l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index          NUMBER;
BEGIN
   l_index := inv_reservation_global.g_supply_record_cache.COUNT+1;
   inv_reservation_global.g_supply_record_cache(l_index)
     := p_supply_record;

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Add_Supply_Cache'
              );
      END IF;

END add_supply_cache;

PROCEDURE search_sub_cache
  (
     x_return_status         OUT NOCOPY VARCHAR2
   , p_subinventory_code     IN  VARCHAR2
   , p_organization_id       IN  NUMBER
   , x_index                 OUT NOCOPY NUMBER
   ) IS
      l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index           NUMBER;
BEGIN
  -- Modified for common API. Secondary_inventory_name replaces
-- subinventory_code

   IF inv_reservation_global.g_sub_record_cache.count > 0 THEN
      l_index := inv_reservation_global.g_sub_record_cache.first ;
      LOOP
	 IF (inv_reservation_global.g_sub_record_cache
	       (l_index).secondary_inventory_name IS NULL
	       AND p_subinventory_code IS NULL
	       OR inv_reservation_global.g_sub_record_cache
	       (l_index).secondary_inventory_name= p_subinventory_code)
	   AND (inv_reservation_global.g_sub_record_cache
	        (l_index).organization_id IS NULL
		AND p_organization_id IS NULL
		OR inv_reservation_global.g_sub_record_cache
		(l_index).organization_id = p_organization_id) THEN
	    EXIT;
	  ELSE
	    IF l_index = inv_reservation_global.g_sub_record_cache.last THEN
	       l_index := NULL;
	       EXIT;
	    END IF;
	    l_index :=
	      inv_reservation_global.g_sub_record_cache.next(l_index) ;
	 END IF;
      END LOOP;
   END IF;

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Search_Sub_Cache'
              );
      END IF;

END search_sub_cache;

PROCEDURE add_sub_cache
  (
     x_return_status   OUT NOCOPY VARCHAR2
   , p_sub_record      IN  inv_reservation_global.sub_record
   , x_index           OUT NOCOPY NUMBER
   ) IS
      l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;
      l_index          NUMBER;
BEGIN
   l_index := inv_reservation_global.g_sub_record_cache.COUNT+1;
   inv_reservation_global.g_sub_record_cache(l_index)
     := p_sub_record;

   x_index := l_index;
   x_return_status := l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
	 fnd_msg_pub.add_exc_msg
	   (  g_pkg_name
              , 'Add_Sub_Cache'
              );
      END IF;

END add_sub_cache;

-- Function
--   locator_control
-- Description
--   Determine whether locator control is on.
--   uses lookup code from mtl_location_controls.
--   see mtl_system_items in the TRM for more
--   information.
--   mtl_location_control lookup code
--      1      no locator control
--      2      prespecified locator control
--      3      dynamic entry locator control
--      4      locator control determined at subinventory level
--      5      locator control determined at item level
--   Since this package is used by reservation only,
--   we will no have dynamic entry locator control at all
--   (if the input is 3, we treats it as 2);
--   also as create, update, delete, or transfer a reservation
--   has no impact on on hand quantity, we will not check
--   negative balance as we do in validation module for
--   cycle count transactions.
-- Return Value
--      a number in (1,2,4,5), as defined in mtl_location_control
--      lookup code
FUNCTION locator_control
  (
     p_org_control  IN    NUMBER
   , p_sub_control  IN    NUMBER
   , p_item_control IN    NUMBER DEFAULT NULL
   ) RETURN NUMBER IS
      l_value           NUMBER;
      l_locator_control NUMBER;
BEGIN

    IF p_org_control = inv_reservation_global.g_locator_control_no THEN
       l_locator_control := inv_reservation_global.g_locator_control_no;
     ELSIF p_org_control =
       inv_reservation_global.g_locator_control_prespecified THEN
       l_locator_control :=
	 inv_reservation_global.g_locator_control_prespecified;
     ELSIF p_org_control =
       inv_reservation_global.g_locator_control_dynamic THEN
       l_locator_control :=
	 inv_reservation_global.g_locator_control_prespecified;
     ELSIF p_org_control = inv_reservation_global.g_locator_control_by_sub THEN
       IF p_sub_control = inv_reservation_global.g_locator_control_no THEN
	  l_locator_control := inv_reservation_global.g_locator_control_no;
	ELSIF p_sub_control =
	  inv_reservation_global.g_locator_control_prespecified THEN
	  l_locator_control :=
	    inv_reservation_global.g_locator_control_prespecified ;
	ELSIF p_sub_control =
	  inv_reservation_global.g_locator_control_dynamic THEN
	  l_locator_control :=
	    inv_reservation_global.g_locator_control_prespecified;
	ELSIF p_sub_control =
	  inv_reservation_global.g_locator_control_by_item THEN
	  IF p_item_control = inv_reservation_global.g_locator_control_no THEN
	     l_locator_control := inv_reservation_global.g_locator_control_no;
	   ELSIF p_item_control =
	     inv_reservation_global.g_locator_control_prespecified THEN
	     l_locator_control :=
	       inv_reservation_global.g_locator_control_prespecified;
	   ELSIF p_item_control =
	     inv_reservation_global.g_locator_control_dynamic THEN
             l_locator_control :=
	       inv_reservation_global.g_locator_control_prespecified;
	   ELSIF p_item_control IS NULL THEN
	     l_locator_control := p_sub_control;
	   ELSE
	     l_value := p_item_control;
	     app_exception.invalid_argument
	       ('LOCATOR.CONTROL','ITEM_LOCATOR_CONTROL',l_value);
	  END IF;
	ELSE
	  l_value := p_sub_control;
	  app_exception.invalid_argument
	    ('LOCATOR.CONTROL','SUB_LOCATOR_CONTROL',l_value);
       END IF;
     ELSE
       l_value := p_org_control;
       app_exception.invalid_argument
	 ('LOCATOR.CONTROL','ORG_LOCATOR_CONTROL',l_value);
    END IF;

    RETURN l_locator_control;

END locator_control;

/*** {{ R12 Enhanced reservations code changes ***/
-- Get_wip_cache will first check if the cache for the wip_entity_id
-- already exists or not. If it's not exist, then call the API
-- inv_reservation_pvt.get_wip_entity to set the wip record cache.
PROCEDURE get_wip_cache
  (
     x_return_status     OUT NOCOPY VARCHAR2
   , p_wip_entity_id     IN  NUMBER
  ) IS
  l_return_status     VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(1000);
  l_wip_entity_type   NUMBER;
  l_wip_job_type      VARCHAR2(15);
BEGIN

  IF (NOT inv_reservation_global.g_wip_record_cache.EXISTS(p_wip_entity_id)) THEN
      -- call get_wip_entity API
      inv_reservation_pvt.get_wip_entity_type
         (  p_api_version_number           => 1.0
          , p_init_msg_lst                 => fnd_api.g_false
          , x_return_status                => l_return_status
          , x_msg_count                    => l_msg_count
          , x_msg_data                     => l_msg_data
          , p_organization_id              => null
          , p_item_id                      => null
          , p_source_type_id               => null
          , p_source_header_id             => p_wip_entity_id
          , p_source_line_id               => null
          , p_source_line_detail           => null
          , x_wip_entity_type              => l_wip_entity_type
          , x_wip_job_type                 => l_wip_job_type
         );

      IF (l_return_status = fnd_api.g_ret_sts_error) THEN
          RAISE fnd_api.g_exc_error;
      ELSIF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      inv_reservation_global.g_wip_record_cache(p_wip_entity_id).wip_entity_id
         := p_wip_entity_id;

      inv_reservation_global.g_wip_record_cache(p_wip_entity_id).wip_entity_type
         := l_wip_entity_type;

      inv_reservation_global.g_wip_record_cache(p_wip_entity_id).wip_entity_job
         := l_wip_job_type;
  END IF;

  x_return_status := l_return_status;
EXCEPTION
  WHEN fnd_api.g_exc_error THEN
     x_return_status := fnd_api.g_ret_sts_error;
     --
  WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
  WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'Add_Wip_Cache'
           );
      END IF;

END get_wip_cache;
/*** End R12 }} ***/

END inv_reservation_util_pvt;

/

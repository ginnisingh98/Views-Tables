--------------------------------------------------------
--  DDL for Package Body WMS_ZONES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ZONES_PVT" AS
/* $Header: WMSZONEB.pls 120.0.12010000.3 2009/08/03 06:45:01 ajunnikr ship $ */

   -- Package     :  WMS_ZONES_PVT
   -- File        : $RCSfile: WMSZONEB.pls,v $
   -- Content     :
   -- Description :  This package provides the following services,
   --                        1.  Table handlers for WMSZONES.fmb
   --                        2.  API's for Zones entitiy
   -- Notes       :
   -- Modified    : Mon Jul 14 14:33:10 GMT+05:30 2003

   /**
   **/
   g_version_printed       BOOLEAN          := FALSE;
   g_pkg_name               VARCHAR2 (30) := 'WMS_ZONES_PVT';

   /**
      *  Flag to indicate whether the initialization of the data
      *  structures (g_locator_types.. .etc, see below) needed to
      *  use this package through the WMSZONES.fmb is done
      *
      *  The default value of this flag is FALSE and is set to true
      *  when the procedure INITIALIZE is called.
      *
      */
   g_initialized                 BOOLEAN          := FALSE;

   TYPE lookup_meaning_table IS TABLE OF mfg_lookups.meaning%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE locator_status_table IS TABLE OF mtl_material_statuses.status_code%TYPE
      INDEX BY BINARY_INTEGER;

   TYPE subinventory_status_table IS TABLE OF mtl_material_statuses.status_code%TYPE
      INDEX BY BINARY_INTEGER;

   g_locator_types       lookup_meaning_table;
   g_subinventory_types  lookup_meaning_table;
   g_locator_status      locator_status_table;
   g_subinventory_status subinventory_status_table;

   g_all_locators_message    VARCHAR2(240);

   PROCEDURE set_locator_status IS

       CURSOR sel_status  IS
       SELECT status_id,
              status_code
       FROM   mtl_material_statuses
       WHERE  locator_control = 1
       AND    enabled_flag = 1;

   BEGIN

      FOR rec IN sel_status  LOOP
         g_locator_status (rec.status_id) := rec.status_code;
      END LOOP;

   END set_locator_status;

   PROCEDURE set_subinventory_status IS

       CURSOR sel_status IS
       SELECT status_id, status_code
       FROM   mtl_material_statuses
       WHERE  zone_control = 1
       AND    enabled_flag = 1;

   BEGIN

      FOR rec IN sel_status LOOP
         g_subinventory_status (rec.status_id) := rec.status_code;
      END LOOP;

   END set_subinventory_status;

   PROCEDURE set_locator_types IS
   BEGIN

      SELECT meaning BULK COLLECT
      INTO   g_locator_types
      FROM   mfg_lookups
      WHERE  lookup_type = 'MTL_LOCATOR_TYPES'
      ORDER BY lookup_code;

   END set_locator_types;

   PROCEDURE set_subinventory_types IS
   BEGIN

      SELECT meaning BULK COLLECT
      INTO   g_subinventory_types
      FROM   mfg_lookups
      WHERE  lookup_type = 'MTL_SUB_TYPES'
      ORDER BY lookup_code;

   END;

   PROCEDURE DEBUG (p_message IN VARCHAR2, p_module IN VARCHAR2, p_level NUMBER) IS

      l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

   BEGIN
      dbms_output.put_line(fnd_profile.VALUE ('INV_DEBUG_FILE'));
--      dbms_output.put_line(p_message);

      IF NOT g_version_printed THEN
         inv_log_util.TRACE ('$Header: WMSZONEB.pls 120.0.12010000.3 2009/08/03 06:45:01 ajunnikr ship $',
                             g_pkg_name,
                             9
                            );
         g_version_printed := TRUE;

      END IF;

      inv_log_util.TRACE (p_message,
                             g_pkg_name || '.' || p_module,
                             p_level
                            );

   END debug;

   PROCEDURE populate_grid (
      p_zone_id                      NUMBER,
      p_org_id                       NUMBER,
      x_record_count    OUT NOCOPY   NUMBER,
      x_return_status   OUT NOCOPY   VARCHAR2,
      x_msg_data        OUT NOCOPY   VARCHAR2
   )  IS

      l_debug NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

      l_progress_indicator VARCHAR2(10) := '0';
      l_module_name        VARCHAR2(15) := 'POPULATE_GRID';

   BEGIN

      DEBUG('In procedure :', l_module_name,0);

      IF l_debug > 0 THEN

          DEBUG ('p_zone_id ' || p_zone_id, l_module_name, 9);
          DEBUG ('p_org_id ' || p_org_id, l_module_name, 9);

      END IF;

      l_progress_indicator := '10';

      /**
        *  This procedure makes use of global data structures, these must be initialized
	*  if not already initialized
	*
        **/

      IF NOT g_initialized THEN

          initialize;

      END IF;

      l_progress_indicator := '20';

      DELETE FROM wms_zone_locators_temp;

      IF l_debug > 0 THEN
          DEBUG ('deleted from wms_zone_locators_temp ' || SQL%ROWCOUNT,
             l_module_name,
             9
            );
      END IF;

      l_progress_indicator := '30';

      INSERT INTO wms_zone_locators_temp(
                     message
                   , message_id
		   , inventory_location_id
		   , locator_name
		   , subinventory_code
		   , picking_order
		   , dropping_order
		   , locator_status
		   , subinventory_status
		   , locator_status_code
		   , subinventory_status_code
		   , inventory_location_type
		   , subinventory_type
		   , locator_type_meaning
		   , subinventory_type_meaning
		   , organization_id) (
      SELECT         NULL
                   , TO_NUMBER(NULL) message_id
                   , wzl.inventory_location_id
		   , milk.concatenated_segments locator_name
		   , wzl.subinventory_code
		   , milk.picking_order
		   , milk.dropping_order
		   , milk.status_id locator_status
		   , msi.status_id subinventory_status
		   , mms1.status_code locator_status_code
		   , mms2.status_code subinventory_status_code
		   , milk.inventory_location_type
		   , msi.subinventory_type
		   , DECODE (milk.inventory_location_type,
                         1, g_locator_types (1),
                         2, g_locator_types (2),
                         3, g_locator_types (3),
                         4, g_locator_types (4),
                         5, g_locator_types (5),
                         6, g_locator_types (6),
                         7, g_locator_types (7),
                         -- Default value is Storage,i.e. 3
                         g_locator_types (3)
                        )
                  , DECODE (msi.subinventory_type,
                         1, g_subinventory_types (1),
                         2, g_subinventory_types (2),
                         -- Default value should be Storage..i.e 1
                         g_subinventory_types(1)
                        )
                   , p_org_id
      FROM      wms_zone_locators wzl,
                mtl_item_locations_kfv milk,
                mtl_secondary_inventories msi,
                mtl_material_statuses mms1,
                mtl_material_statuses mms2
      WHERE     wzl.zone_id = p_zone_id
      AND       wzl.organization_id = p_org_id
      AND       NVL(wzl.entire_sub_flag,'N') = 'N'
      AND       wzl.organization_id  = msi.organization_id
      AND       wzl.subinventory_code = msi.secondary_inventory_name
      AND       wzl.organization_id  = milk.organization_id
      AND       wzl.subinventory_code = milk.subinventory_code
      AND       wzl.inventory_location_id = milk.inventory_location_id
      AND       mms1.status_id(+) = milk.status_id
      AND       mms2.status_id(+) = msi.status_id
      UNION
      SELECT         NULL
                   , TO_NUMBER(NULL) message_id
                   , wzl.inventory_location_id
		   , g_all_locators_message locator_name
		   , wzl.subinventory_code
		   , TO_NUMBER(NULL)  picking_order
		   , TO_NUMBER(NULL)  dropping_orders
		   , TO_NUMBER(NULL) locator_status
		   , msi.status_id subinventory_status
		   , NULL locator_status_code
		   , mms.status_code subinventory_status_code
		   , TO_NUMBER(NULL)
		   , msi.subinventory_type
		   , NULL
                   , DECODE (msi.subinventory_type,
                         1, g_subinventory_types (1),
                         2, g_subinventory_types (2),
                         -- The default value should be Storage, i.e. 1
                         g_subinventory_types (1)
                        )
                   , p_org_id
      FROM      wms_zone_locators wzl,
                mtl_secondary_inventories msi,
                mtl_material_statuses mms
      WHERE     wzl.zone_id = p_zone_id
      AND       wzl.organization_id = p_org_id
      AND       NVL(wzl.entire_sub_flag,'N') = 'Y'
      AND       wzl.organization_id  = msi.organization_id
      AND       wzl.subinventory_code = msi.secondary_inventory_name
      AND       mms.status_id = msi.status_id
                                       );

        IF l_debug > 0 THEN

           DEBUG ('no. of records in serted ' || SQL%ROWCOUNT, l_module_name, 9);

        END IF;

        l_progress_indicator := '40';

        x_return_status := fnd_api.g_ret_sts_success;

        DEBUG('Call Success', l_module_name,0);

    EXCEPTION

        WHEN OTHERS THEN

             DEBUG ('Unexpected exception : '|| l_progress_indicator
	                                     ||' : ' || SQLERRM,
                l_module_name,
                9
               );
         x_return_status := fnd_api.g_ret_sts_unexp_error;
	 --x_msg_count     := 1;
	 x_msg_data      := substr(SQLERRM, 200);

   END populate_grid;

   /**
    *   Using the filter criteria given in the Add Locators form,
    *   inserts the locators into the table WMS_ZONE_LOCATORS_TEMP.
    *
    *  @param   p_fm_zone_id      from_zone_id in the range. Will have a
    *                             null value if the user doesnt choose a from_zone
    *  @param   p_to_zone_id      to_zone_id in the range. Can have a null
    *                             value if the user doesnt choose a to_zone
    *  @param   p_current_zone_id The zone_id of the current zone,
    *                             for which more locators are being added
    *  @param   p_fm_sub_code     From Subinventory code
    *  @param   p_to_sub_code     To Subinventory Code
    *  @param   p_fm_loc_id       From Locator Id in a range of locators.
    *                             Should contain a value only if either
    *                             p_fm_sub_code or p_to_sub_code is populated.
    *  @param   p_to_loc_id       To Locator Id in a range of locators.
    *                             Should contain a value only if either
    *                             p_fm_sub_code or p_to_sub_code is populated.
    *  @param   p_subinventory_status    Status id of the subinventories
    *  @param   p_locator_status    Status id of the locators
    *  @param   p_subinventory_type    Subinventory Type
    *  @param   p_locator_type    Locator Type
    *  @param   p_fm_picking_order    Picking order of the Locators
    *  @param   p_to_picking_order    Picking order of the Locators
    *  @param   p_fm_dropping_order    Dropping order of the Locators
    *  @param   p_to_dropping_order    Dropping order of the Locators
    *  @param   p_organization_id      Organization identifier
    **/
   PROCEDURE add_locators_to_grid (
      p_fm_zone_id            IN   NUMBER DEFAULT NULL,
      p_to_zone_id            IN   NUMBER DEFAULT NULL,
      p_current_zone_id       IN   NUMBER DEFAULT NULL,
      p_fm_sub_code           IN   VARCHAR2 DEFAULT NULL,
      p_to_sub_code           IN   VARCHAR2 DEFAULT NULL,
      p_fm_loc_id             IN   NUMBER DEFAULT NULL,
      p_to_loc_id             IN   NUMBER DEFAULT NULL,
      p_subinventory_status   IN   NUMBER DEFAULT NULL,
      p_locator_status        IN   NUMBER DEFAULT NULL,
      p_subinventory_type     IN   NUMBER DEFAULT NULL,
      p_locator_type          IN   NUMBER DEFAULT NULL,
      p_fm_picking_order      IN   NUMBER DEFAULT NULL,
      p_to_picking_order      IN   NUMBER DEFAULT NULL,
      p_fm_dropping_order     IN   NUMBER DEFAULT NULL,
      p_to_dropping_order     IN   NUMBER DEFAULT NULL,
      p_organization_id       IN   NUMBER,
      p_mode IN NUMBER DEFAULT NULL,
      p_type IN VARCHAR2 default 'A') IS
      l_insert_str             VARCHAR2 (2000);
      l_select_str             VARCHAR2 (2000);
      l_from_str               VARCHAR2 (2000);
      l_where_str              VARCHAR2 (2000);
      g_add_locator_message    wms_zone_locators_temp.MESSAGE%TYPE;
      l_query_str              VARCHAR2 (4000);
      l_query_handle           NUMBER;
      l_query_count            NUMBER;
      l_progress               VARCHAR2 (10) := '0';
      l_is_all_locators        BOOLEAN := FALSE;

      l_module_name   VARCHAR2 (30)        := 'ADD_LOCATORS_TO_GRID';
      l_debug         NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
      l_progress_indicator     VARCHAR2(10) := '0';

      -- Zone enhancement
      l_jtf_message wms_zone_locators_temp.MESSAGE%TYPE;
      l_jtf_message_id VARCHAR2(4) := 'NULL';

      -- bug 3659062
      l_fm_loc_name mtl_item_locations_kfv.concatenated_segments%TYPE;
      l_to_loc_name mtl_item_locations_kfv.concatenated_segments%TYPE;

   BEGIN

      DEBUG('In procedure :', l_module_name,0);

      IF (l_debug = 1) THEN

         DEBUG ('  p_fm_zone_id==> ' || p_fm_zone_id, l_module_name, 9);
         DEBUG ('  p_to_zone_id==> ' || p_to_zone_id, l_module_name, 9);
         DEBUG ('  p_current_zone_id==> ' || p_current_zone_id,
                l_module_name,
                9
               );
         DEBUG ('  p_fm_sub_code==> ' || p_fm_sub_code, l_module_name, 9);
         DEBUG ('  p_to_sub_code==> ' || p_to_sub_code, l_module_name, 9);
         DEBUG ('  p_fm_loc_id==> ' || p_fm_loc_id, l_module_name, 9);
         DEBUG ('  p_to_loc_id==> ' || p_to_loc_id, l_module_name, 9);
         DEBUG ('  p_subinventory_status==> ' || p_subinventory_status,
                l_module_name,
                9
               );
         DEBUG ('  p_locator_status==> ' || p_locator_status, l_module_name,
                9);
         DEBUG ('  p_subinventory_type==> ' || p_subinventory_type,
                l_module_name,
                9
               );
         DEBUG ('  p_locator_type==> ' || p_locator_type, l_module_name, 9);
         DEBUG ('  p_fm_picking_order==> ' || p_fm_picking_order,
                l_module_name,
                9
               );
         DEBUG ('  p_to_picking_order==> ' || p_to_picking_order,
                l_module_name,
                9
               );
         DEBUG ('  p_fm_dropping_order==> ' || p_fm_dropping_order,
                l_module_name,
                9
               );
         DEBUG ('  p_to_dropping_order==> ' || p_to_dropping_order,
                l_module_name,
                9
               );
         DEBUG ('  p_mode==> ' || p_mode,
                l_module_name,
                9
               );

      END IF; /* Debug = 1 */


      l_progress_indicator := '10';

      /**
        *  This procedure makes use of global data structures, these must be initialized
	*  if not already initialized
	*
        **/

      IF NOT g_initialized THEN

          initialize;

      END IF;


      -- enhancement

      IF(Nvl(p_mode, 1) = 1) THEN
	 -- only in view/modify mode, populate message when OK is pressed
	 l_jtf_message_id := '1';
	 l_jtf_message := wms_zones_pvt.g_add_locators_message;
       ELSE
	 -- clear the temp table if OK was pressed in ADD or REMOVE mode
	 DELETE wms_zone_locators_temp;
      END IF;

      l_progress_indicator := '20';

      -- bug 3659062

      IF(p_fm_loc_id IS NOT NULL AND p_fm_loc_id <> -999) THEN
	 SELECT concatenated_segments
	   INTO l_fm_loc_name
	   FROM mtl_item_locations_kfv
	   WHERE inventory_location_id = p_fm_loc_id
	   AND organization_id = p_organization_id;
      END IF;

      IF(p_to_loc_id IS NOT NULL AND p_to_loc_id <> -999) THEN
	 SELECT concatenated_segments
	   INTO l_to_loc_name
	   FROM mtl_item_locations_kfv
	   WHERE inventory_location_id = p_to_loc_id
	   AND organization_id = p_organization_id;
      END IF;

      l_insert_str :=
         'INSERT INTO wms_zone_locators_temp(
                                      message,
                                      message_id,
                                      inventory_location_id,
                                      locator_name,
                                      subinventory_code,
                                      picking_order,
                                      dropping_order,
                                      locator_status,
                                      subinventory_status,
                                      locator_status_code,
                                      subinventory_status_code,
                                      inventory_location_type,
                                      subinventory_type,
                                      locator_type_meaning,
                                      subinventory_type_meaning,
                                      organization_id)';

      l_progress_indicator := '30';

      IF p_fm_zone_id IS NOT NULL THEN

         l_progress_indicator := '40';

         l_is_all_locators := TRUE;

         l_select_str :=
                '(SELECT '''
             || l_jtf_message
             || ''','
             || l_jtf_message_id ||' , wzlv.inventory_location_id,
                     nvl(wzlv.locator_name,:all_locators),
                     wzlv.subinventory_code,
                     wzlv.picking_order,
                     wzlv.dropping_order,
                     wzlv.locator_status,
                     wzlv.subinventory_status,
                     mms1.status_code locator_status_code,
                     mms2.status_code subinventory_status_code,';

         DEBUG ('10 l_select_str is ' || l_select_str, l_module_name, 9);
         l_select_str :=
                l_select_str
             || 'wzlv.inventory_location_type, wzlv.subinventory_type, ';
         DEBUG ('20 l_insert_str is ' || l_select_str, ' add_locators_grid',
                9);
         l_select_str :=
                l_select_str
             || 'decode(wzlv.inventory_location_type,1, '''
             || g_locator_types (1)
             || ''',2,'''
             || g_locator_types (2)
             || ''',3,'''
             || g_locator_types (3)
             || ''', 4, '''
             || g_locator_types (4)
             || ''', 5,'''
             || g_locator_types (5)
             || ''', 6,'''
             || g_locator_types (6)
             || ''', 7,'''
             || g_locator_types (7)
             || ''', '''
             || g_locator_types (3)
             || '''),';
         DEBUG ('30 l_insert_str is ' || l_select_str, ' add_locators_grid',
                9);
         l_select_str :=
                l_select_str
             || 'decode(wzlv.subinventory_type,1, '''
             || g_subinventory_types (1)
             || ''',2, '''
             || g_subinventory_types (2)
             || ''', '''
             || g_subinventory_types (1)
             || ''') , '||p_organization_id;
         DEBUG ('40 l_select_str is ' || l_select_str, ' add_locators_grid',
                9);
         l_from_str :=
            ' from wms_zone_locators_v wzlv, mtl_material_statuses mms1, mtl_material_statuses mms2';
         DEBUG ('l_from_str is ' || l_from_str, l_module_name, 9);
         l_where_str :=
               l_where_str
               || ' where mms1.status_id(+) = wzlv.locator_status ';
         l_where_str :=
                l_where_str
             || ' and mms2.status_id(+) = wzlv.subinventory_status ';
         l_where_str :=
                l_where_str
             || ' and zone_id between :fm_zone_id and nvl(:to_zone_id,:fm_zone_id) ';
         l_where_str :=
                 l_where_str
                 || ' and wzlv.organization_id = :organization_id ';
         DEBUG ('10 l_where_str is ' || l_where_str, ' add_locators_grid', 9);

         IF p_fm_sub_code IS NOT NULL AND p_to_sub_code IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and wzlv.subinventory_code between :fm_sub_code and :to_sub_code ';
            DEBUG ('20 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_sub_code IS NOT NULL AND p_to_sub_code IS NULL
         THEN
            l_where_str :=
                 l_where_str
                 || ' and wzlv.subinventory_code >= :fm_sub_code ';
            DEBUG ('30 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_sub_code IS NULL AND p_to_sub_code IS NOT NULL
         THEN
            l_where_str :=
                 l_where_str
                 || ' and wzlv.subinventory_code <= :to_sub_code ';
            DEBUG ('40 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_fm_loc_id IS NOT NULL AND p_to_loc_id IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and wzlv.locator_name between :fm_loc_name and :to_loc_name';       -- bug 3659062

            DEBUG ('50 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_loc_id IS NOT NULL AND p_to_loc_id IS NULL
         THEN
            l_where_str :=
                l_where_str
                || ' and wzlv.locator_name >= :fm_loc_name';      -- bug 3659062

            DEBUG ('60 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_loc_id IS NULL AND p_to_loc_id IS NOT NULL
         THEN
            l_where_str :=
                l_where_str
                || ' and wzlv.locator_name <= :to_loc_name';      -- bug 3659062

            DEBUG ('70 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_fm_picking_order IS NOT NULL AND p_to_picking_order IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and wzlv.picking_order between :fm_picking_order and :to_picking_order';
            DEBUG ('80 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_picking_order IS NOT NULL AND p_to_picking_order IS NULL
         THEN
            l_where_str :=
                 l_where_str
                 || ' and wzlv.picking_order >= :fm_picking_order';
            DEBUG ('90 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_picking_order IS NULL AND p_to_picking_order IS NOT NULL
         THEN
            l_where_str :=
                 l_where_str
                 || ' and wzlv.picking_order <= :to_picking_order';
            DEBUG ('100 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_fm_dropping_order IS NOT NULL
            AND p_to_dropping_order IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and wzlv.dropping_order between :fm_dropping_order and :to_dropping_order)';
            DEBUG ('110 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_dropping_order IS NOT NULL AND p_to_dropping_order IS NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and wzlv.dropping_order >= :fm_dropping_order';
            DEBUG ('120 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_dropping_order IS NULL AND p_to_dropping_order IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and wzlv.dropping_order <= :to_dropping_order';
            DEBUG ('130 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_locator_type IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and wzlv.inventory_location_type = :locator_type ';
            DEBUG ('140 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_subinventory_type IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and wzlv.subinventory_type = :subinventory_type ';
            DEBUG ('150 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_locator_status IS NOT NULL
         THEN
            l_where_str :=
                  l_where_str
                  || ' and wzlv.locator_status = :locator_status ';
            DEBUG ('160 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_subinventory_status IS NOT NULL
         THEN
            l_where_str :=
                 l_where_str
                 || ' and wzlv.subinventory_status = :sub_status ';
            DEBUG ('170 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;
      ELSE --zone_id is null
         DEBUG ('zone id is null ' || wms_zones_pvt.g_add_locators_message,
                l_module_name,
                9
               );
         l_is_all_locators := FALSE;
         l_select_str :=
                '(SELECT '''
             || l_jtf_message
             || ''','
             || l_jtf_message_id ||',
                     milk.inventory_location_id,
                     milk.concatenated_segments,
                     milk.subinventory_code,
                     milk.picking_order,
                     milk.dropping_order,
                     milk.status_id,
                     msi.status_id subinventory_status,
                     mms1.status_code locator_status_code,
                     mms2.status_code subinventory_status_code,';
         DEBUG ('10 l_select_str is ' || l_select_str, ' add_locators_grid',
                9);
         l_select_str :=
                 l_select_str
                 || 'inventory_location_type, subinventory_type, ';
         DEBUG ('20 l_select_str is ' || l_select_str, ' add_locators_grid',
                9);
         l_select_str :=
                l_select_str
             || 'decode(milk.inventory_location_type,1, '''
             || g_locator_types (1)
             || ''',2,'''
             || g_locator_types (2)
             || ''',3,'''
             || g_locator_types (3)
             || ''', 4, '''
             || g_locator_types (4)
             || ''', 5,'''
             || g_locator_types (5)
             || ''', 6,'''
             || g_locator_types (6)
             || ''', 7,'''
             || g_locator_types (7)
             || ''', '''
             || g_locator_types (3)
             || '''),';
         DEBUG ('30 l_select_str is ' || l_select_str, ' add_locators_grid',
                9);
         l_select_str :=
                l_select_str
             || 'decode(msi.subinventory_type,1, '''
             || g_subinventory_types (1)
             || ''',2, '''
             || g_subinventory_types (2)
             || ''', '''
             || g_subinventory_types (1)
             || ''') , '||p_organization_id;
         DEBUG ('40 l_select_str is ' || l_select_str, ' add_locators_grid',
                9);
         l_from_str :=
            ' from mtl_item_locations_kfv milk, mtl_secondary_inventories msi,
             mtl_material_statuses mms1,mtl_material_statuses mms2 ';
         DEBUG ('10 l_from_str is ' || l_from_str, ' add_locators_grid', 9);
         l_where_str := ' where 1=1 ';
         DEBUG ('10 l_where_str is ' || l_where_str, ' add_locators_grid', 9);
         l_where_str :=
                 l_where_str
                 || ' and mms1.status_id(+) = milk.status_id ';
         l_where_str :=
                        l_where_str
                        || ' and mms2.status_id(+) = msi.status_id';
         l_where_str :=
                   l_where_str
                   || ' and msi.organization_id = :organization_id';
         l_where_str :=
                  l_where_str
                  || ' and milk.organization_id = :organization_id';
         l_where_str :=
                l_where_str
             || ' and milk.subinventory_code = msi.secondary_inventory_name ';
         l_where_str :=
                l_where_str
                || ' and nvl(milk.disable_date,SYSDATE) >= SYSDATE';
         DEBUG ('20 l_where_str is ' || l_where_str, ' add_locators_grid', 9);

         /* p_fm_zone_id is null. There are 3 cases here- */
         IF p_fm_sub_code IS NOT NULL OR p_to_sub_code IS NOT NULL
         THEN
            IF p_fm_sub_code IS NOT NULL AND p_to_sub_code IS NOT NULL
            THEN
               l_where_str :=
                      l_where_str
                   || ' and milk.subinventory_code between :fm_sub_code and :to_sub_code ';
               DEBUG ('20 l_where_str is ' || l_where_str,
                      ' add_locators_grid',
                      9
                     );
            ELSIF p_fm_sub_code IS NOT NULL AND p_to_sub_code IS NULL
            THEN
               l_where_str :=
                      l_where_str
                   || ' and milk.subinventory_code >= :fm_sub_code ';
               DEBUG ('30 l_where_str is ' || l_where_str,
                      ' add_locators_grid',
                      9
                     );
            ELSIF p_fm_sub_code IS NULL AND p_to_sub_code IS NOT NULL
            THEN
               l_where_str :=
                      l_where_str
                   || ' and milk.subinventory_code <= :to_sub_code ';
               DEBUG ('40 l_where_str is ' || l_where_str,
                      ' add_locators_grid',
                      9
                     );
            ELSE
               l_where_str := l_where_str || ' and null ';
               DEBUG ('50 l_where_str is ' || l_where_str,
                      ' add_locators_grid',
                      9
                     );
            END IF;

            /* Case 1 - When only a range of subinventories is selected. Locators
             * field is null. Then We have to chose all the locators in these subs
             * which are not already present in the current zone -This includes
             * "All Locators" option also
             */
            IF p_fm_loc_id IS NULL AND p_to_loc_id IS NULL
	      THEN
	       NULL;
            ELSIF     p_fm_loc_id IS NOT NULL
                  AND p_fm_loc_id <> -999
                  AND p_to_loc_id IS NOT NULL
                  AND p_to_loc_id <> -999
            THEN
               l_where_str :=
                      l_where_str
                   || ' and milk.concatenated_segments between :fm_loc_name and :to_loc_name ';      -- bug 3659062

               DEBUG ('20 l_where_str is ' || l_where_str,
                      ' add_locators_grid',
                      9
                     );
            ELSIF p_fm_loc_id IS NOT NULL AND p_to_loc_id IS NULL
            THEN
               l_where_str :=
                      l_where_str
                   || ' and milk.concatenated_segments >= :fm_loc_name ';      -- bug 3659062

               DEBUG ('30 l_where_str is ' || l_where_str,
                      ' add_locators_grid',
                      9
                     );
            ELSIF p_fm_loc_id IS NULL AND p_to_loc_id IS NOT NULL
            THEN
               l_where_str :=
                      l_where_str
                   || ' and milk.concatenated_segments <= :fm_loc_name ';      -- bug 3659062

               DEBUG ('40 l_where_str is ' || l_where_str,
                      ' add_locators_grid',
                      9
                     );
            END IF;
         END IF;

         IF p_fm_picking_order IS NOT NULL AND p_to_picking_order IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and milk.picking_order between :fm_picking_order and :to_picking_order';
            DEBUG ('50 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_picking_order IS NOT NULL AND p_to_picking_order IS NULL
         THEN
            l_where_str :=
                 l_where_str
                 || ' and milk.picking_order >= :fm_picking_order';
            DEBUG ('60 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_picking_order IS NULL AND p_to_picking_order IS NOT NULL
         THEN
            l_where_str :=
                 l_where_str
                 || ' and milk.picking_order <= :to_picking_order';
            DEBUG ('70 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_fm_dropping_order IS NOT NULL
            AND p_to_dropping_order IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and milk.dropping_order between :fm_dropping_order and :to_dropping_order';
            DEBUG ('80 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_dropping_order IS NOT NULL AND p_to_dropping_order IS NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and milk.dropping_order >= :fm_dropping_order';
            DEBUG ('90 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         ELSIF p_fm_dropping_order IS NULL AND p_to_dropping_order IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and milk.dropping_order <= :to_dropping_order';
            DEBUG ('100 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_locator_type IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and milk.inventory_location_type = :locator_type ';
            DEBUG ('110 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_subinventory_type IS NOT NULL
         THEN
            l_where_str :=
                   l_where_str
                || ' and msi.subinventory_type = :subinventory_type ';
            DEBUG ('120 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_locator_status IS NOT NULL
         THEN
            l_where_str :=
                  l_where_str
                  || ' and milk.status_id = :locator_status ';
            DEBUG ('130 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;

         IF p_subinventory_status IS NOT NULL
         THEN
            l_where_str := l_where_str || ' and msi.status_id = :sub_status ';
            DEBUG ('140 l_where_str is ' || l_where_str,
                   ' add_locators_grid',
                   9
                  );
         END IF;
      END IF;


-- Ajith added
  -- Zone enhancement as a part of Wave Planning project
      -- If the zone is a labor planning zone, we should not allow the user to add locators that belong to another labor planning zone

      if p_type = 'L' THEN


       l_where_str :=
	   l_where_str
	   || ' and inventory_location_id not in (select inventory_location_id from wms_zone_locators wzl, wms_zones_vl wz where
	   wz.zone_id=wzl.zone_id and wz.zone_type=''L'') ';

	 end if;

      -- Zone enhancement
      -- It's a bug fix: no matter what, we need to restrict locators returned
      -- based on locators belonging to the current zone.
      -- In add and view/modify mode exclude those locators belonging to the current zone already;
      -- in remove mode, include only locators belonging to the current zone.

      IF (Nvl(p_mode, 1) <> 3) THEN
	 l_where_str :=
	   l_where_str
	   || ' and inventory_location_id not in ';
       ELSE -- remove mode
	 -- Zone enhancement
	 -- In remove mode, retrieve the intersect of query criteria and current zone
	 l_where_str :=
	   l_where_str
	   || ' and inventory_location_id in ';
      END IF;



      DEBUG ('60 l_where_str is ' || l_where_str,
	     ' add_locators_grid',
	     9
	     );
      l_where_str :=
	l_where_str
	|| ' (select locator_id from wms_zone_locators_all_v
	where zone_id =  :cur_zone_id) ';
	DEBUG ('70 l_where_str is ' || l_where_str,
	       ' add_locators_grid',
	       9
	       );


      DEBUG ('from string ' || l_from_str, l_module_name, 9);
      DEBUG ('where string ' || l_where_str, l_module_name, 9);
      l_select_str := l_select_str || l_from_str || l_where_str || ')';
      DEBUG ('select string ' || l_select_str, l_module_name, 9);
      l_query_str := l_insert_str || l_select_str;
      DEBUG ('final query string ' || l_query_str, l_module_name, 9);
      DEBUG ('handling and parsing the query', l_module_name, 9);
      l_query_handle := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (l_query_handle, l_query_str, DBMS_SQL.native);
      DEBUG ('after parsing -- enw ', l_module_name, 9);
      DEBUG ('parsing ', l_module_name, 9);

      IF p_organization_id IS NOT NULL
      THEN
         DEBUG ('Assigning Organization' || p_organization_id,
                l_module_name,
                9
               );
         DBMS_SQL.bind_variable (l_query_handle,
                                 ':organization_id',
                                 p_organization_id
                                );
      END IF;

      -- Zone enhancement
      -- It's a bug fix: no matter what, we need to restrict locators returned
      -- based on locators belonging to the current zone.
      DEBUG ('80-3', 'add_locators_grid', 9);
      DBMS_SQL.bind_variable (l_query_handle,
			      'cur_zone_id',
			      p_current_zone_id
			      );
      DEBUG ('60', 'add_locators_grid', 9);

      IF l_is_all_locators
      THEN
         DEBUG ('assigning locators: ' || g_all_locators_message, l_module_name, 9);
         DBMS_SQL.bind_variable (l_query_handle,
                                 'all_locators',
                                 g_all_locators_message
                                );
         DEBUG ('150', 'add_locators_grid', 9);
      END IF;

      IF p_fm_loc_id IS NOT NULL AND p_fm_loc_id <> -999
      THEN
         DEBUG ('fm locid is not null', 'add_locators_grid', 9);
         DBMS_SQL.bind_variable (l_query_handle, 'fm_loc_name', l_fm_loc_name);      -- bug 3659062

         DEBUG ('90-1', 'add_locators_grid', 9);
      END IF;

      IF p_to_loc_id IS NOT NULL AND p_to_loc_id <> -999
      THEN
         DEBUG ('to locid is not null', 'add_locators_grid', 9);
         DBMS_SQL.bind_variable (l_query_handle, 'to_loc_name', l_to_loc_name);      -- bug 3659062

         DEBUG ('90-2', 'add_locators_grid', 9);
      END IF;

      IF p_subinventory_status IS NOT NULL
      THEN
         DEBUG ('assigning substatus ' || p_subinventory_status,
                l_module_name,
                9
               );
         DBMS_SQL.bind_variable (l_query_handle,
                                 'sub_status',
                                 p_subinventory_status
                                );
         DEBUG ('70', 'add_locators_grid', 9);
      END IF;

      IF p_locator_status IS NOT NULL
      THEN
         DEBUG ('assigning locator status ' || p_locator_status,
                'add_locators_grid',
                9
               );
         DBMS_SQL.bind_variable (l_query_handle,
                                 'locator_status',
                                 p_locator_status
                                );
         DEBUG ('80', 'add_locators_grid', 9);
      END IF;

      IF p_fm_sub_code IS NOT NULL
      THEN
         DEBUG ('Assigning fm_sub_code' || p_fm_sub_code, l_module_name, 9);
         DBMS_SQL.bind_variable (l_query_handle, 'fm_sub_code',
                                 p_fm_sub_code);
         DEBUG ('40', 'add_locators_grid', 9);
      END IF;

      IF p_to_sub_code IS NOT NULL
      THEN
         DEBUG ('Assigning to_sub_code' || p_to_sub_code, l_module_name, 9);
         DBMS_SQL.bind_variable (l_query_handle, 'to_sub_code',
                                 p_to_sub_code);
         DEBUG ('50', 'add_locators_grid', 9);
      END IF;

      DEBUG ('My changed pls', l_module_name, 9);

      IF p_fm_zone_id IS NOT NULL
      THEN
         DEBUG ('assigning fmzone ' || p_fm_zone_id, l_module_name, 9);
         DBMS_SQL.bind_variable (l_query_handle, 'fm_zone_id', p_fm_zone_id);
         DEBUG ('10', 'add_locators_grid', 9);
         --END IF;

         -- IF p_to_zone_id IS NOT NULL THEN
         DEBUG ('assigning to zone ' || p_to_zone_id, l_module_name, 9);
         DBMS_SQL.bind_variable (l_query_handle, 'to_zone_id', p_to_zone_id);
         DEBUG ('20', 'add_locators_grid', 9);
      END IF;

      IF p_subinventory_type IS NOT NULL
      THEN
         DEBUG ('assigning sub type ' || p_subinventory_type,
                l_module_name,
                9
               );
         DBMS_SQL.bind_variable (l_query_handle,
                                 'subinventory_type',
                                 p_subinventory_type
                                );
         DEBUG ('400', 'add_locators_grid', 9);
      END IF;

      IF p_locator_type IS NOT NULL
      THEN
         DEBUG ('assigning loc type ' || p_locator_type, l_module_name, 9);
         DBMS_SQL.bind_variable (l_query_handle,
                                 'locator_type',
                                 p_locator_type
                                );
         DEBUG ('410', 'add_locators_grid', 9);
      END IF;

      IF p_fm_picking_order IS NOT NULL
      THEN
         DEBUG (' assigning fm picking order ' || p_fm_picking_order,
                l_module_name,
                9
               );
         DBMS_SQL.bind_variable (l_query_handle,
                                 'fm_picking_order',
                                 p_fm_picking_order
                                );
         DEBUG ('110', 'add_locators_grid', 9);
      END IF;

      IF p_to_picking_order IS NOT NULL
      THEN
         DEBUG (' assigning to picking order ' || p_to_picking_order,
                l_module_name,
                9
               );
         DBMS_SQL.bind_variable (l_query_handle,
                                 'to_picking_order',
                                 p_to_picking_order
                                );
         DEBUG ('120', 'add_locators_grid', 9);
      END IF;

      IF p_fm_dropping_order IS NOT NULL
      THEN
         DEBUG (' assigning fm dropping order ' || p_fm_dropping_order,
                l_module_name,
                9
               );
         DBMS_SQL.bind_variable (l_query_handle,
                                 'fm_dropping_order',
                                 p_fm_dropping_order
                                );
         DEBUG ('130', 'add_locators_grid', 9);
      END IF;

      IF p_to_dropping_order IS NOT NULL
      THEN
         DEBUG (' assigning to dropping order ' || p_to_dropping_order,
                l_module_name,
                9
               );
         DBMS_SQL.bind_variable (l_query_handle,
                                 'to_dropping_order',
                                 p_to_dropping_order
                                );
         DEBUG ('140', 'add_locators_grid', 9);
      END IF;

    /* Parse, bind and execute the dynamic query */
/*
    IF p_fm_zone_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, 'fm_zone_id', p_fm_zone_id);
      DEBUG('10', 'add_locators_grid', 9);
    END IF;

    IF p_to_zone_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, 'to_zone_id', p_to_zone_id);
      DEBUG('20', 'add_locators_grid', 9);
    END IF;

    IF p_current_zone_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(
        l_query_handle
      , 'current_zone_id'
      , p_current_zone_id
      );
      DEBUG('30', 'add_locators_grid', 9);
    END IF;

    IF p_fm_sub_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, 'fm_sub_code', p_fm_sub_code);
      DEBUG('40', 'add_locators_grid', 9);
    END IF;

    IF p_to_sub_code IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, 'to_sub_code', p_to_sub_code);
      DEBUG('50', 'add_locators_grid', 9);
    END IF;

    IF p_fm_loc_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, 'fm_loc_name', l_fm_loc_name);      -- bug 3659062

      DEBUG('60', 'add_locators_grid', 9);
    END IF;

    IF p_to_loc_id IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, 'to_loc_name', l_to_loc_name);      -- bug 3659062

      DEBUG('70', 'add_locators_grid', 9);
    END IF;

    IF p_locator_status IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, 'locator_status', p_locator_status);
      DEBUG('90', 'add_locators_grid', 9);
    END IF;

    IF p_subinventory_type IS NOT NULL THEN
      DBMS_SQL.bind_variable(
        l_query_handle
      , 'subinventory_type'
      , p_subinventory_type
      );
      DEBUG('100', 'add_locators_grid', 9);
    END IF;

    --IF p_subinventory_status IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, ':sub_status', 1);
      DEBUG('70', 'add_locators_grid', 9);
  --  END IF;

    IF p_fm_picking_order IS NOT NULL THEN
      DBMS_SQL.bind_variable(
        l_query_handle
      , 'fm_picking_order'
      , p_fm_picking_order
      );
      DEBUG('110', 'add_locators_grid', 9);
    END IF;

    IF p_to_picking_order IS NOT NULL THEN
      DBMS_SQL.bind_variable(
        l_query_handle
      , 'to_picking_order'
      , p_to_picking_order
      );
      DEBUG('120', 'add_locators_grid', 9);
    END IF;

    IF p_fm_dropping_order IS NOT NULL THEN
      DBMS_SQL.bind_variable(
        l_query_handle
      , 'fm_dropping_order'
      , p_fm_dropping_order
      );
      DEBUG('130', 'add_locators_grid', 9);
    END IF;

    IF p_to_dropping_order IS NOT NULL THEN
      DBMS_SQL.bind_variable(
        l_query_handle
      , 'to_dropping_order'
      , p_to_dropping_order
      );
      DEBUG('140', 'add_locators_grid', 9);
    END IF;

    IF p_all_locators IS NOT NULL THEN
      DBMS_SQL.bind_variable(l_query_handle, 'all_locators', p_all_locators);
      DEBUG('150', 'add_locators_grid', 9);
    END IF; */
      l_query_count := DBMS_SQL.EXECUTE (l_query_handle);
      COMMIT;
      DEBUG ('l_query_count ' || l_query_count, 'add_locators_grid', 9);
   END add_locators_to_grid;

   /**
     *   Contains code to insert records into wms_zones_b and
     *   wms_zones_tl

     *  @param  x_return_status   Return Status - Success, Error, Unexpected Error
     *  @param  x_msg_data   Contains any error messages added to the stack
     *  @param  x_msg_count   Contains the count of the messages added to the stack
     *  @param  p_zone_id   Zone_id
     *  @param  p_zone_name   Name of the new Zone
     *  @param  p_description   Description of the zone
     *  @param  enabled_flag   Flag to indicate whether the zone is enabled or not. '
                               Y' indicates that the zone is enabled.
                               'N' indicates that the zone is not enabled.
                               Any other value will be an error
     *  @param  disable_date   The date when the zone will be disabled.
                               This date cannot be less than the SYSDATE.
     *  @param  p_organization_id   Current Organization id
     *  @param  p_attribute_category   Attribute Category of the Zones Descriptive Flexfield
     *  @param  p_attribute1   Attribute1
     *  @param  p_attribute2   Attribute2
     *  @param  p_attribute3   Attribute3
     *  @param  p_attribute4   Attribute4
     *  @param  p_attribute5   Attribute5
     *  @param  p_attribute6   Attribute6
     *  @param  p_attribute7   Attribute7
     *  @param  p_attribute8   Attribute8
     *  @param  p_attribute9   Attribute9
     *  @param  p_attribute10   Attribute10
     *  @param  p_attribute11   Attribute11
     *  @param  p_attribute12   Attribute12
     *  @param  p_attribute13   Attribute13
     *  @param  p_attribute14   Attribute14
     *  @param  p_attribute15   Attribute15
   **/
   PROCEDURE insert_wms_zones (
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      p_zone_id              IN              NUMBER,
      p_zone_name            IN              VARCHAR2,
      p_description          IN              VARCHAR2,
      p_type                   in varchar2,
      p_enabled_flag         IN              VARCHAR2,
      p_labor_enabled        IN              VARCHAR2,
      p_disable_date         IN              DATE,
      p_organization_id      IN              NUMBER,
      p_attribute_category   IN              VARCHAR2,
      p_attribute1           IN              VARCHAR2,
      p_attribute2           IN              VARCHAR2,
      p_attribute3           IN              VARCHAR2,
      p_attribute4           IN              VARCHAR2,
      p_attribute5           IN              VARCHAR2,
      p_attribute6           IN              VARCHAR2,
      p_attribute7           IN              VARCHAR2,
      p_attribute8           IN              VARCHAR2,
      p_attribute9           IN              VARCHAR2,
      p_attribute10          IN              VARCHAR2,
      p_attribute11          IN              VARCHAR2,
      p_attribute12          IN              VARCHAR2,
      p_attribute13          IN              VARCHAR2,
      p_attribute14          IN              VARCHAR2,
      p_attribute15          IN              VARCHAR2,
      p_creation_date        IN              DATE,
      p_created_by           IN              NUMBER,
      p_last_update_date     IN              DATE,
      p_last_updated_by      IN              NUMBER,
      p_last_update_login    IN              NUMBER
   ) IS

      l_debug              NUMBER       := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
      l_module_name        VARCHAR2(20) := 'INSERT_WMS_ZONES';
      l_progress_indicator VARCHAR2(10) := '0';

      l_return_status VARCHAR2(1);
      l_msg_data      VARCHAR2(2000);
      l_msg_count     NUMBER;

      l_rowid         VARCHAR2(200);

   BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      DEBUG('In procedure :', l_module_name,0);

      IF (l_debug = 1) THEN

         DEBUG (' p_zone_id==> ' || p_zone_id, l_module_name, 9);
         DEBUG (' p_zone_name==> ' || p_zone_name, l_module_name, 9);
         DEBUG (' p_description==> ' || p_description, l_module_name, 9);
         DEBUG (' enabled_flag==> ' || p_enabled_flag, l_module_name, 9);
         DEBUG (' p_labor_enabled==> ' || p_labor_enabled, l_module_name, 9);
         DEBUG (' disable_date==> ' || p_disable_date, l_module_name, 9);
         DEBUG (' p_organization_id==> ' || p_organization_id,
                l_module_name,
                9
               );
         DEBUG (' p_attribute_category==> ' || p_attribute_category,
                l_module_name,
                9
               );
         DEBUG (' p_attribute1==> ' || p_attribute1, l_module_name, 9);
         DEBUG (' p_attribute2==> ' || p_attribute2, l_module_name, 9);
         DEBUG (' p_attribute3==> ' || p_attribute3, l_module_name, 9);
         DEBUG (' p_attribute4==> ' || p_attribute4, l_module_name, 9);
         DEBUG (' p_attribute5==> ' || p_attribute5, l_module_name, 9);
         DEBUG (' p_attribute6==> ' || p_attribute6, l_module_name, 9);
         DEBUG (' p_attribute7==> ' || p_attribute7, l_module_name, 9);
         DEBUG (' p_attribute8==> ' || p_attribute8, l_module_name, 9);
         DEBUG (' p_attribute9==> ' || p_attribute9, l_module_name, 9);
         DEBUG (' p_attribute10==> ' || p_attribute10, l_module_name, 9);
         DEBUG (' p_attribute11==> ' || p_attribute11, l_module_name, 9);
         DEBUG (' p_attribute12==> ' || p_attribute12, l_module_name, 9);
         DEBUG (' p_attribute13==> ' || p_attribute13, l_module_name, 9);
         DEBUG (' p_attribute14==> ' || p_attribute14, l_module_name, 9);
         DEBUG (' p_attribute15==> ' || p_attribute15, l_module_name, 9);
         DEBUG (' p_creation_date==> ' || p_creation_date,
                l_module_name,
                9
               );
         DEBUG (' p_last_update_date==> ' || p_last_update_date,
                l_module_name,
                9
               );
         DEBUG (' created_by==> ' || p_created_by, l_module_name, 9);
         DEBUG (' p_last_update_login==> ' || p_last_update_login,
                l_module_name,
                9
               );
         DEBUG (' p_last_updated_by==> ' || p_last_updated_by,
                l_module_name,
                9
               );

      END IF; /* l_debug = 1 */

      l_progress_indicator := '10';

    WMS_ZONES_PKG.INSERT_ROW (
                   X_ROWID              => l_rowid,
                   X_ZONE_ID            => p_zone_id,
                   X_ATTRIBUTE_CATEGORY => p_attribute_category,
                   X_ATTRIBUTE1         => p_attribute1,
                   X_ATTRIBUTE2         => p_attribute2,
                   X_ATTRIBUTE3         => p_attribute3,
                   X_ATTRIBUTE4         => p_attribute4,
                   X_ATTRIBUTE5         => p_attribute5,
                   X_ATTRIBUTE6         => p_attribute6,
                   X_ATTRIBUTE7         => p_attribute7,
                   X_ATTRIBUTE8         => p_attribute8,
                   X_ATTRIBUTE9         => p_attribute9,
                   X_ATTRIBUTE10        => p_attribute10,
                   X_ATTRIBUTE11        => p_attribute11,
                   X_ATTRIBUTE12        => p_attribute12,
                   X_ATTRIBUTE13        => p_attribute13,
                   X_ATTRIBUTE14        => p_attribute14,
                   X_ATTRIBUTE15        => p_attribute15,
                   X_ORGANIZATION_ID    => p_organization_id,
                   X_DISABLE_DATE       => p_disable_date,
                   X_ENABLED_FLAG       => p_enabled_flag,
                   X_LABOR_ENABLED      => p_labor_enabled,
                   X_ZONE_NAME          => p_zone_name,
                   X_ZONE_TYPE=>p_type,
                   X_DESCRIPTION        => p_description,
                   X_CREATION_DATE      => p_creation_date,
                   X_CREATED_BY         => p_created_by,
                   X_LAST_UPDATE_DATE   => p_last_update_date,
                   X_LAST_UPDATED_BY    => p_last_updated_by,
                   X_LAST_UPDATE_LOGIN  => p_last_update_login
                               );




      IF l_debug > 0 THEN

         DEBUG (' Inserted row with rowid ' || l_rowid,
                l_module_name,
                9
               );

      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      DEBUG('Call Success', l_module_name,0);

   EXCEPTION
      WHEN OTHERS THEN

         DEBUG('Unexpected Exception :' ||l_progress_indicator
	                                ||' : '||SQLERRM ,
               l_module_name,0);

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM, 200);
         x_msg_count     := 1;

   END insert_wms_zones;

   /**
     *   Contains code to update records in wms_zones_b and
     *   wms_zones_tl

     *  @param  x_return_status   Return Status - Success, Error, Unexpected Error
     *  @param  x_msg_data   Contains any error messages added to the stack
     *  @param  x_msg_count   Contains the count of the messages added to the stack
     *  @param  p_zone_id   Zone_id
     *  @param  p_zone_name   Name of the new Zone
     *  @param  p_description   Description of the zone
     *  @param  enabled_flag   Flag to indicate whether the zone is enabled or not. 'Y' indicates that the zone is enabled 'N' indicates that the zone is not enabled. Any other value will be an error
     *  @param  disable_date   The date when the zone will be disabled. This date cannot be less than the SYSDATE.
     *  @param  p_organization_id   Current Organization id
     *  @param  p_attribute_category   Attribute Category of the Zones Descriptive Flexfield
     *  @param  p_attribute1   Attribute1
     *  @param  p_attribute2   Attribute2
     *  @param  p_attribute3   Attribute3
     *  @param  p_attribute4   Attribute4
     *  @param  p_attribute5   Attribute5
     *  @param  p_attribute6   Attribute6
     *  @param  p_attribute7   Attribute7
     *  @param  p_attribute8   Attribute8
     *  @param  p_attribute9   Attribute9
     *  @param  p_attribute10   Attribute10
     *  @param  p_attribute11   Attribute11
     *  @param  p_attribute12   Attribute12
     *  @param  p_attribute13   Attribute13
     *  @param  p_attribute14   Attribute14
     *  @param  p_attribute15   Attribute15


   **/
   PROCEDURE update_wms_zones (
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      p_zone_id              IN              NUMBER,
      p_zone_name            IN              VARCHAR2,
      p_description          IN              VARCHAR2,
       p_type                   in varchar2,
      p_enabled_flag         IN              VARCHAR2,
      p_labor_enabled        IN              VARCHAR2,
      p_disable_date         IN              DATE,
      p_organization_id      IN              NUMBER,
      p_attribute_category   IN              VARCHAR2,
      p_attribute1           IN              VARCHAR2,
      p_attribute2           IN              VARCHAR2,
      p_attribute3           IN              VARCHAR2,
      p_attribute4           IN              VARCHAR2,
      p_attribute5           IN              VARCHAR2,
      p_attribute6           IN              VARCHAR2,
      p_attribute7           IN              VARCHAR2,
      p_attribute8           IN              VARCHAR2,
      p_attribute9           IN              VARCHAR2,
      p_attribute10          IN              VARCHAR2,
      p_attribute11          IN              VARCHAR2,
      p_attribute12          IN              VARCHAR2,
      p_attribute13          IN              VARCHAR2,
      p_attribute14          IN              VARCHAR2,
      p_attribute15          IN              VARCHAR2,
      p_creation_date        IN              DATE,
      p_created_by           IN              NUMBER,
      p_last_update_date     IN              DATE,
      p_last_updated_by      IN              NUMBER,
      p_last_update_login    IN              NUMBER
   ) IS
      l_debug              NUMBER       := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
      l_module_name        VARCHAR2(20) := 'UPDATE_WMS_ZONES';
      l_progress_indicator VARCHAR2(10) := '0';

      l_return_status VARCHAR2(1);
      l_msg_data      VARCHAR2(2000);
      l_msg_count     NUMBER;

   BEGIN

      x_return_status := fnd_api.g_ret_sts_success;

      DEBUG('In procedure :', l_module_name,0);

      IF (l_debug = 1) THEN

         DEBUG (' p_zone_id==> ' || p_zone_id, l_module_name, 9);
         DEBUG (' p_zone_name==> ' || p_zone_name, l_module_name, 9);
         DEBUG (' p_description==> ' || p_description, l_module_name, 9);
         DEBUG (' enabled_flag==> ' || p_enabled_flag, l_module_name, 9);
         DEBUG (' p_labor_enabled==> ' || p_labor_enabled, l_module_name, 9);
         DEBUG (' disable_date==> ' || p_disable_date, l_module_name, 9);
         DEBUG (' p_organization_id==> ' || p_organization_id,
                l_module_name,
                9
               );
         DEBUG (' p_attribute_category==> ' || p_attribute_category,
                l_module_name,
                9
               );
         DEBUG (' p_attribute1==> ' || p_attribute1, l_module_name, 9);
         DEBUG (' p_attribute2==> ' || p_attribute2, l_module_name, 9);
         DEBUG (' p_attribute3==> ' || p_attribute3, l_module_name, 9);
         DEBUG (' p_attribute4==> ' || p_attribute4, l_module_name, 9);
         DEBUG (' p_attribute5==> ' || p_attribute5, l_module_name, 9);
         DEBUG (' p_attribute6==> ' || p_attribute6, l_module_name, 9);
         DEBUG (' p_attribute7==> ' || p_attribute7, l_module_name, 9);
         DEBUG (' p_attribute8==> ' || p_attribute8, l_module_name, 9);
         DEBUG (' p_attribute9==> ' || p_attribute9, l_module_name, 9);
         DEBUG (' p_attribute10==> ' || p_attribute10, l_module_name, 9);
         DEBUG (' p_attribute11==> ' || p_attribute11, l_module_name, 9);
         DEBUG (' p_attribute12==> ' || p_attribute12, l_module_name, 9);
         DEBUG (' p_attribute13==> ' || p_attribute13, l_module_name, 9);
         DEBUG (' p_attribute14==> ' || p_attribute14, l_module_name, 9);
         DEBUG (' p_attribute15==> ' || p_attribute15, l_module_name, 9);
         DEBUG (' p_creation_date==> ' || p_creation_date,
                l_module_name,
                9
               );
         DEBUG (' p_last_update_date==> ' || p_last_update_date,
                l_module_name,
                9
               );
         DEBUG (' created_by==> ' || p_created_by, l_module_name, 9);
         DEBUG (' p_last_update_login==> ' || p_last_update_login,
                l_module_name,
                9
               );
         DEBUG (' p_last_updated_by==> ' || p_last_updated_by,
                l_module_name,
                9
               );

      END IF; /* l_debug = 1 */

      l_progress_indicator := '10';

      WMS_ZONES_PKG.UPDATE_ROW (
                   X_ZONE_ID            => p_zone_id,
                   X_ATTRIBUTE_CATEGORY => p_attribute_category,
                   X_ATTRIBUTE1         => p_attribute1,
                   X_ATTRIBUTE2         => p_attribute2,
                   X_ATTRIBUTE3         => p_attribute3,
                   X_ATTRIBUTE4         => p_attribute4,
                   X_ATTRIBUTE5         => p_attribute5,
                   X_ATTRIBUTE6         => p_attribute6,
                   X_ATTRIBUTE7         => p_attribute7,
                   X_ATTRIBUTE8         => p_attribute8,
                   X_ATTRIBUTE9         => p_attribute9,
                   X_ATTRIBUTE10        => p_attribute10,
                   X_ATTRIBUTE11        => p_attribute11,
                   X_ATTRIBUTE12        => p_attribute12,
                   X_ATTRIBUTE13        => p_attribute13,
                   X_ATTRIBUTE14        => p_attribute14,
                   X_ATTRIBUTE15        => p_attribute15,
                   X_ORGANIZATION_ID    => p_organization_id,
                   X_DISABLE_DATE       => p_disable_date,
                   X_ENABLED_FLAG       => p_enabled_flag,
                   X_LABOR_ENABLED      => p_labor_enabled,
                   X_ZONE_NAME          => p_zone_name,
                   X_DESCRIPTION        => p_description,
                    X_ZONE_TYPE => p_type,
                   X_LAST_UPDATE_DATE   => p_last_update_date,
                   X_LAST_UPDATED_BY    => p_last_updated_by,
                   X_LAST_UPDATE_LOGIN  => p_last_update_login
                               );

      IF l_debug > 0 THEN

         DEBUG (' After updating wms_zones_b/tl' ,
                l_module_name,
                9
               );

      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      DEBUG('Call Success', l_module_name,0);

   EXCEPTION
      WHEN NO_DATA_FOUND THEN

         DEBUG('No data found Exception :' ||l_progress_indicator
	                                ||' : '||SQLERRM ,
               l_module_name,0);

         x_return_status := fnd_api.g_ret_sts_error;
         x_msg_data      := substrb(SQLERRM, 200);
         x_msg_count     := 1;

      WHEN OTHERS THEN
         DEBUG('Unexpected Exception :' ||l_progress_indicator
	                                ||' : '||SQLERRM ,
               l_module_name,0);

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substrb(SQLERRM, 200);
         x_msg_count     := 1;

   END update_wms_zones;

   /**
    *   This procedure saves the records from
    *   wms_zone_locators_temp to wms_zone_locators. For every
    *   record at a given index in the table p_zoneloc_messages
    *   table, we get the the corresponding rowid from the input
    *   parameter table p_zoneloc_rowid_t for the same index.
    *   If the value in p_zoneloc_messages_t is 0, the
    *   corresponding record will be inserted into the table.
    *   If the value in p_zoneloc_messages_t is 1, the
    *   corresponding record will be deleted from the table.
    *   Else do nothing.

    *  @param  p_zoneloc_rowid_t   Table of records containing the rowids of all the records to be inserted or deleted.
    *  @param  p_zoneloc_messages_t   Indicates whether the corresponding record should be inserted or deleted.
  If the value is 0, the corresponding record will be inserted into the table.
  If the value is 1, the corresponding record will be deleted from the table.
  Else do nothing.
    **/
   PROCEDURE save_sel_locators (
      p_zoneloc_rowid_t   IN   wms_zones_pvt.zoneloc_rowid_t,
      p_zone_id           IN   wms_zone_locators.zone_id%TYPE
   ) IS

      l_progress_indicator VARCHAR2(10) := '0';
      l_module_name        VARCHAR2(20) := 'SAVE_SEL_LOCATORS';
      l_debug              NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

   BEGIN

      DEBUG('In procedure :', l_module_name,0);

      IF (l_debug > 1) THEN

         DEBUG(' p_zone_id ==> ' || p_zone_id, l_module_name, 9);
         DEBUG(' Rows ==> '||p_zoneloc_rowid_t.COUNT, l_module_name, 9);

      END IF;

      l_progress_indicator := '10';

      FORALL i IN p_zoneloc_rowid_t.FIRST .. p_zoneloc_rowid_t.LAST
         DELETE FROM wms_zone_locators
         WHERE  ROWID IN (
           SELECT wzl.ROWID
           FROM   wms_zone_locators wzl,
                  wms_zone_locators_temp wzlt
           WHERE  wzl.zone_id = p_zone_id
           AND    wzlt.rowid = p_zoneloc_rowid_t(i)
           AND    wzlt.message_id = 1
           AND    wzl.organization_id = wzlt.organization_id
           AND    wzl.subinventory_code = wzlt.subinventory_code
           AND    NVL(wzlt.inventory_location_id, -999) = -999
                         );

      IF(l_debug > 0) THEN

        DEBUG('Rows deleted before insert :'||SQL%ROWCOUNT, l_module_name, 9);

      END IF;

      l_progress_indicator := '20';

      FORALL i IN p_zoneloc_rowid_t.FIRST .. p_zoneloc_rowid_t.LAST
         INSERT INTO wms_zone_locators (
                     organization_id
                   , zone_id
                   , inventory_location_id
                   , subinventory_code
                   , entire_sub_flag
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , last_update_login
                                       ) (
              SELECT wzlt.organization_id
                   , p_zone_id
                   , DECODE(wzlt.inventory_location_id,
                            -999
                           , NULL
                           , wzlt.inventory_location_id)
                   , wzlt.subinventory_code
                   , DECODE(wzlt.inventory_location_id,
                            -999
                           , 'Y'
                           , NULL
                           , 'Y'
                           , 'N')
                   , SYSDATE
                   , fnd_global.user_id
                   , SYSDATE
                   , fnd_global.user_id
                   , fnd_global.login_id
              FROM  wms_zone_locators_temp wzlt
              WHERE wzlt.message_id  = 1
              AND   ROWID = p_zoneloc_rowid_t (i)
              AND NOT EXISTS (
                  SELECT 1
                  FROM   wms_zone_locators wzl
                  WHERE  wzl.zone_id = p_zone_id
                  AND    wzl.organization_id = wzlt.organization_id
                  AND    wzl.subinventory_code = wzlt.subinventory_code
                  AND    wzl.entire_sub_flag = 'Y'
                             )
              AND NOT EXISTS (
                  SELECT 1
                  FROM   wms_zone_locators wzl
                  WHERE  wzl.zone_id = p_zone_id
                  AND    wzl.organization_id = wzlt.organization_id
                  AND    wzl.subinventory_code = wzlt.subinventory_code
                  AND    NVL(wzl.entire_sub_flag,'N') = 'N'
                  AND    wzl.inventory_location_id = wzlt.inventory_location_id
                             )
                                      );

      IF(l_debug > 0) THEN

        DEBUG('Rows inserted :'||SQL%ROWCOUNT, l_module_name, 9);

      END IF;

      l_progress_indicator := '30';

      FORALL i IN p_zoneloc_rowid_t.FIRST .. p_zoneloc_rowid_t.LAST
         DELETE FROM wms_zone_locators
         WHERE  ROWID IN (
           SELECT wzl.ROWID
           FROM   wms_zone_locators wzl,
                  wms_zone_locators_temp wzlt
           WHERE  wzl.zone_id = p_zone_id
           AND    wzlt.rowid = p_zoneloc_rowid_t(i)
           AND    wzlt.message_id = 2
           AND    wzl.organization_id = wzlt.organization_id
           AND    wzl.subinventory_code = wzlt.subinventory_code
           AND    ( ( wzlt.inventory_location_id IS NULL ) OR
                    ( wzl.inventory_location_id = wzlt.inventory_location_id ) ) );

      IF(l_debug > 0) THEN

        DEBUG('Rows removed from zone :'||SQL%ROWCOUNT, l_module_name, 9);

      END IF;

      DEBUG('Call Success', l_module_name,0);

   EXCEPTION

      WHEN OTHERS THEN
         DEBUG (' Unexpected exception : ' || SQLERRM, l_module_name, 0);

   END save_sel_locators;

   PROCEDURE save_all_locators (
      p_zone_id   IN   wms_zone_locators.zone_id%TYPE,
      p_org_id    IN   wms_zone_locators.organization_id%TYPE
   )
   IS
      l_org_id              NUMBER;
      l_zone_id             NUMBER;
      l_inv_loc_id          NUMBER;
      l_sub_code            VARCHAR2 (10);
      l_entire_sub          VARCHAR2 (1);
      l_last_update_date    DATE;
      l_last_updated_by     NUMBER;
      l_creation_date       DATE;
      l_created_by          NUMBER;
      l_last_update_login   NUMBER;
   BEGIN
      DEBUG (' p_zone_id==> ' || p_zone_id, 'save_all_locators', 9);
      DEBUG (' p_org_id==> ' || p_org_id, 'save_all_locators', 9);

      INSERT INTO wms_zone_locators
                  (organization_id, zone_id, inventory_location_id,
                   subinventory_code, entire_sub_flag, last_update_date,
                   last_updated_by, creation_date, created_by,
                   last_update_login)
         (SELECT p_org_id, p_zone_id, inventory_location_id,
                 subinventory_code,
                 DECODE (inventory_location_id, -999, 'Y', 'N'), SYSDATE,
                 fnd_global.user_id, SYSDATE, fnd_global.user_id,
                 fnd_global.user_id
            FROM wms_zone_locators_temp
           WHERE MESSAGE_ID = 1 );

      DEBUG ('committing' || SQL%ROWCOUNT, 'save_all_locators', 9);

      DELETE FROM wms_zone_locators
            WHERE inventory_location_id =
                     (SELECT inventory_location_id
                        FROM wms_zone_locators_temp
                       WHERE MESSAGE_id = 2)
              AND zone_id = p_zone_id;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         DEBUG (' other exception ' || SQLERRM, 'save_all_locators', 9);
   END save_all_locators;


   PROCEDURE lock_row(
                      x_return_status       OUT NOCOPY VARCHAR2,
                      x_msg_data            OUT NOCOPY VARCHAR2,
                      x_msg_count           OUT NOCOPY NUMBER,
                      p_zone_id             IN         NUMBER,
                      p_zone_name           IN         VARCHAR2,
                      p_description         IN         VARCHAR2,
                       p_type                   in varchar2,
                      p_enabled_flag        IN         VARCHAR2,
                      p_labor_enabled       IN         VARCHAR2,
                      p_disable_date        IN         DATE,
                      p_organization_id     IN         NUMBER,
                      p_attribute_category  IN         VARCHAR2,
                      p_attribute1          IN         VARCHAR2,
                      p_attribute2          IN         VARCHAR2,
                      p_attribute3          IN         VARCHAR2,
                      p_attribute4          IN         VARCHAR2,
                      p_attribute5          IN         VARCHAR2,
                      p_attribute6          IN         VARCHAR2,
                      p_attribute7          IN         VARCHAR2,
                      p_attribute8          IN         VARCHAR2,
                      p_attribute9          IN         VARCHAR2,
                      p_attribute10         IN         VARCHAR2,
                      p_attribute11         IN         VARCHAR2,
                      p_attribute12         IN         VARCHAR2,
                      p_attribute13         IN         VARCHAR2,
                      p_attribute14         IN         VARCHAR2,
                      p_attribute15         IN         VARCHAR2,
                      p_creation_date       IN         DATE,
                      p_created_by          IN         NUMBER,
                      p_last_update_date    IN         DATE,
                      p_last_updated_by     IN         NUMBER,
                      p_last_update_login   IN         NUMBER
                     ) IS
      l_module_name CONSTANT VARCHAR2(30) := 'LOCK_ROW';

      CURSOR C1 IS
      SELECT *
      FROM   WMS_ZONES_VL
      WHERE  ZONE_ID = P_ZONE_ID
      FOR UPDATE OF ZONE_ID NOWAIT;

      rec1 C1%ROWTYPE;

      record_changed EXCEPTION;

   BEGIN

      OPEN C1;
      FETCH C1 INTO REC1;
      IF C1%NOTFOUND THEN
         RAISE NO_DATA_FOUND;
      END IF;
      CLOSE C1;

      IF ( (rec1.zone_id = p_zone_id) AND
           (rec1.organization_id = p_organization_id) AND
           ( (rec1.zone_name = p_zone_name) OR
             (rec1.zone_name IS NULL AND p_zone_name IS NULL) ) AND
           ( (rec1.enabled_flag = p_enabled_flag) OR
             (rec1.enabled_flag IS NULL AND p_enabled_flag IS NULL) ) AND
           ( (rec1.labor_enabled = p_labor_enabled) OR
             (rec1.labor_enabled IS NULL AND p_labor_enabled IS NULL) ) AND
           ( (rec1.description = p_description) OR
             (rec1.description IS NULL AND p_description IS NULL) ) AND
             	   ( (rec1.zone_type = p_type) OR
             (rec1.zone_type IS NULL AND p_type IS NULL) ) AND
           ( (rec1.disable_date = p_disable_date) OR
             (rec1.disable_date IS NULL AND p_disable_date IS NULL) ) AND
           ( (rec1.created_by = p_created_by) OR
             (rec1.created_by IS NULL AND p_created_by IS NULL) ) AND
           ( (rec1.creation_date = p_creation_date) OR
             (rec1.creation_date IS NULL AND p_creation_date IS NULL) ) AND
           ( (rec1.last_updated_by = p_last_updated_by) OR
             (rec1.last_updated_by IS NULL AND p_last_updated_by IS NULL) ) AND
           ( (rec1.last_update_date = p_last_update_date) OR
             (rec1.last_update_date IS NULL AND p_last_update_date IS NULL) ) AND
           ( (rec1.last_update_login = p_last_update_login) OR
             (rec1.last_update_login IS NULL AND p_last_update_login IS NULL) ) AND
           ( (rec1.attribute_category = p_attribute_category) OR
             (rec1.attribute_category IS NULL AND p_attribute_category IS NULL) ) AND
           ( (rec1.attribute1 = p_attribute1) OR
             (rec1.attribute1 IS NULL AND p_attribute1 IS NULL) ) AND
           ( (rec1.attribute2 = p_attribute2) OR
             (rec1.attribute2 IS NULL AND p_attribute2 IS NULL) ) AND
           ( (rec1.attribute3 = p_attribute3) OR
             (rec1.attribute3 IS NULL AND p_attribute3 IS NULL) ) AND
           ( (rec1.attribute4 = p_attribute4) OR
             (rec1.attribute4 IS NULL AND p_attribute4 IS NULL) ) AND
           ( (rec1.attribute5 = p_attribute5) OR
             (rec1.attribute5 IS NULL AND p_attribute5 IS NULL) ) AND
           ( (rec1.attribute6 = p_attribute6) OR
             (rec1.attribute6 IS NULL AND p_attribute6 IS NULL) ) AND
           ( (rec1.attribute7 = p_attribute7) OR
             (rec1.attribute7 IS NULL AND p_attribute7 IS NULL) ) AND
           ( (rec1.attribute8 = p_attribute8) OR
             (rec1.attribute8 IS NULL AND p_attribute8 IS NULL) ) AND
           ( (rec1.attribute9 = p_attribute9) OR
             (rec1.attribute9 IS NULL AND p_attribute9 IS NULL) ) AND
           ( (rec1.attribute10 = p_attribute10) OR
             (rec1.attribute10 IS NULL AND p_attribute10 IS NULL) ) AND
           ( (rec1.attribute11 = p_attribute11) OR
             (rec1.attribute11 IS NULL AND p_attribute11 IS NULL) ) AND
           ( (rec1.attribute12 = p_attribute12) OR
             (rec1.attribute12 IS NULL AND p_attribute12 IS NULL) ) AND
           ( (rec1.attribute13 = p_attribute13) OR
             (rec1.attribute13 IS NULL AND p_attribute13 IS NULL) ) AND
           ( (rec1.attribute14 = p_attribute14) OR
             (rec1.attribute14 IS NULL AND p_attribute14 IS NULL) ) AND
           ( (rec1.attribute15 = p_attribute15) OR
             (rec1.attribute15 IS NULL AND p_attribute15 IS NULL) )
         ) THEN

           NULL;
      ELSE

         RAISE record_changed;

      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_msg_pub.count_and_get(
                                p_count => x_msg_count,
                                p_data  => x_msg_data
                               );

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_return_status := fnd_api.g_ret_sts_error;

         fnd_message.set_name('INV','OE_LOCK_ROW_DELETED');
         fnd_msg_pub.add;

         fnd_msg_pub.count_and_get(
                                   p_count => x_msg_count,
                                   p_data  => x_msg_data
                                  );

      WHEN app_exceptions.record_lock_exception THEN
         x_return_status := fnd_api.g_ret_sts_error;

         fnd_message.set_name('INV','OE_LOCK_ROW_ALREADY_LOCKED');
         fnd_msg_pub.add;

         fnd_msg_pub.count_and_get(
                                   p_count => x_msg_count,
                                   p_data  => x_msg_data
                                  );


      WHEN record_changed THEN
         x_return_status := fnd_api.g_ret_sts_error;

         fnd_message.set_name('INV','OE_LOCK_ROW_CHANGED');
         fnd_msg_pub.add;

         fnd_msg_pub.count_and_get(
                                   p_count => x_msg_count,
                                   p_data  => x_msg_data
                                  );


      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         x_msg_data := substrb(sqlerrm, 200);
         x_msg_count := 1;

         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_module_name);

         END IF;

   END LOCK_ROW;

   /**
    *   Initialize the data structures needed for procedures of this package to work.
    *
    *   This procedure must always be called once before any call is made to any other
    *   procedure/function of this package.
    *
    *   If any exception is raised during the process of initialization, the same will is
    *   propagated
    *
    **/
   PROCEDURE initialize IS

        l_progress_indicator VARCHAR2(10) := '0';
        l_module_name        VARCHAR2(15) := 'INITIALIZE';

   BEGIN

        DEBUG('In procedure :', l_module_name,0);

        l_progress_indicator := '10';

         /**
           *  If the data structures have already been initialized then no need to do any
           *  furthur processing, return immediately.
           */
         IF g_initialized THEN

             DEBUG('Call Success', l_module_name,0);
             RETURN;

         END IF;

          /**
            *  In case g_initialized is NULL, make it FALSE
            */
         g_initialized := FALSE;

         l_progress_indicator := '20';
	 set_locator_status;

         l_progress_indicator := '30';
         set_subinventory_status;

         l_progress_indicator := '40';
	 set_locator_types;

         l_progress_indicator := '50';
         set_subinventory_types;

         l_progress_indicator := '60';
	 populate_message_cache;

         g_initialized := TRUE;

	 DEBUG('Call Success', l_module_name,0);

   EXCEPTION

         WHEN OTHERS THEN
               g_initialized := FALSE;
               DEBUG('Unexpected Exception :' ||l_progress_indicator
	                                                           ||' : '||SQLERRM ,
                            l_module_name,0);
               RAISE;

   END initialize;

   /**
    *   Caches the commonly used message texts in global variables
    *
    **/
   PROCEDURE populate_message_cache IS

        l_progress_indicator VARCHAR2(10) := '0';
        l_module_name        VARCHAR2(25) := 'POPULATE_MESSAGE_CACHE';

   BEGIN

       DEBUG('In procedure :', l_module_name,0);

       l_progress_indicator := '10';
       fnd_message.set_name('WMS', 'WMS_PENDING_ADDITION_TO_ZONE');
       g_add_locators_message  := fnd_message.get;

       l_progress_indicator := '20';
       fnd_message.set_name('WMS', 'WMS_PENDING_REMOVAL_FROM_ZONE');
       g_remove_locators_message  := fnd_message.get;

       l_progress_indicator := '30';
       fnd_message.set_name('WMS', 'WMS_ALL_LOCATORS');
       g_all_locators_message  := fnd_message.get;

       DEBUG('Call Success', l_module_name,0);

   EXCEPTION

      WHEN OTHERS THEN
         DEBUG('Unexpected Exception :' ||l_progress_indicator
	                                ||' : '||SQLERRM ,
               l_module_name,0);
         RAISE;

   END populate_message_cache;

   /**
    *   Validate the attributes of Zones.
    *
    *   If any validation fails the procedure sets the x_return_status to 'E'.
    *   If any truncation occurs during validation the x_return status is set to 'W'
    *
    *   Any exception raised during the process of validation is put on the stack
    *
    *  @param  x_return_status       Return status, this can be 'S', 'E' or 'W'
    *  @param  x_msg_count           Count of messages in stack
    *  @param  x_msg_data            Message, if the count is 1
    *  @param  p_zone_id             Zone id
    *  @param  p_zone_name           Zone name
    *  @param  p_description         Description
    *  @param  p_enabled_flag        Enabled flag
    *  @param  p_disable_date        Disable date
    *  @param  p_organization_id     Organization id
    *  @param  p_attribute_category  Zone DFF context field
    *  @param  p_attribute1          Zone DFF Attribute
    *  @param  p_attribute2          Zone DFF Attribute
    *  @param  p_attribute3          Zone DFF Attribute
    *  @param  p_attribute4          Zone DFF Attribute
    *  @param  p_attribute5          Zone DFF Attribute
    *  @param  p_attribute6          Zone DFF Attribute
    *  @param  p_attribute7          Zone DFF Attribute
    *  @param  p_attribute8          Zone DFF Attribute
    *  @param  p_attribute9          Zone DFF Attribute
    *  @param  p_attribute10         Zone DFF Attribute
    *  @param  p_attribute11         Zone DFF Attribute
    *  @param  p_attribute12         Zone DFF Attribute
    *  @param  p_attribute13         Zone DFF Attribute
    *  @param  p_attribute14         Zone DFF Attribute
    *  @param  p_attribute15         Zone DFF Attribute
    *  @param  p_creation_date       WHO column
    *  @param  p_created_by          WHO column
    *  @param  p_last_update_date    WHO column
    *  @param  p_last_updated_by     WHO column
    *  @param  p_last_update_login   WHO column
    *
    **/
   PROCEDURE validate_row(
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_msg_data            OUT NOCOPY VARCHAR2,
                          x_msg_count           OUT NOCOPY NUMBER,
                          p_zone_id             IN         NUMBER,
                          p_zone_name           IN         VARCHAR2,
                          p_description         IN         VARCHAR2,
                          p_enabled_flag        IN         VARCHAR2,
                          p_disable_date        IN         DATE,
                          p_organization_id     IN         NUMBER,
                          p_attribute_category  IN         VARCHAR2,
                          p_attribute1          IN         VARCHAR2,
                          p_attribute2          IN         VARCHAR2,
                          p_attribute3          IN         VARCHAR2,
                          p_attribute4          IN         VARCHAR2,
                          p_attribute5          IN         VARCHAR2,
                          p_attribute6          IN         VARCHAR2,
                          p_attribute7          IN         VARCHAR2,
                          p_attribute8          IN         VARCHAR2,
                          p_attribute9          IN         VARCHAR2,
                          p_attribute10         IN         VARCHAR2,
                          p_attribute11         IN         VARCHAR2,
                          p_attribute12         IN         VARCHAR2,
                          p_attribute13         IN         VARCHAR2,
                          p_attribute14         IN         VARCHAR2,
                          p_attribute15         IN         VARCHAR2,
                          p_creation_date       IN         DATE,
                          p_created_by          IN         NUMBER,
                          p_last_update_date    IN         DATE,
                          p_last_updated_by     IN         NUMBER,
                          p_last_update_login   IN         NUMBER
                         ) IS

      l_progress_indicator VARCHAR2(10) := '0';
      l_module_name        VARCHAR2(30) := 'VALIDATE_ROW';

      l_return_status      VARCHAR2(1)  := 'S';
      l_zone_name          VARCHAR2(40);

      l_id                 NUMBER;

      CURSOR c_zone_id IS
      SELECT 1
      FROM   wms_zones_b
      WHERE  zone_id = p_zone_id;

      CURSOR c_org_id IS
      SELECT 1
      FROM   mtl_parameters
      WHERE  organization_id = p_organization_id;

      CURSOR c_zone_name IS
      SELECT 1
      FROM   wms_zones_vl
      WHERE  zone_name = p_zone_name
      AND    organization_id = p_organization_id;

   BEGIN

      DEBUG('In procedure :', l_module_name,0);

      l_progress_indicator := '10';

      /**
       *  The disable date must be greater than or equal to SYSDATE
       **/
      IF p_disable_date < SYSDATE THEN

         l_return_status := 'E';
         fnd_message.set_name('WMS','WMS_ZONE_DISABLE_INAVLID');
         fnd_msg_pub.ADD;

      END IF;

      l_progress_indicator := '20';

      /**
       *  The Enabled flag can only be NULL or Y or N
       **/
      IF p_enabled_flag IS NULL OR
         p_enabled_flag = 'Y' OR
         p_enabled_flag = 'N' THEN

         NULL;

      ELSE

         l_return_status := 'E';
         fnd_message.set_name('WMS','WMS_ZONE_ENABLED_INVALID');
         fnd_msg_pub.ADD;

      END IF;

      l_progress_indicator := '30';

      /**
       *  The Description field is only 240 bytes long
       **/
      IF LENGTH(p_description) > 240 THEN

         fnd_message.set_name('WMS','WMS_DESCRIP_TOO_LONG');
         fnd_msg_pub.ADD;

         IF l_return_status = 'S' THEN
            l_return_status := 'W';
         END IF;

      END IF;

      l_progress_indicator := '40';

      /**
       *  The Zone Name field is only 30 bytes long
       **/
      IF LENGTH(p_zone_name) > 30 THEN

         fnd_message.set_name('WMS','WMS_ZONE_TOO_LONG');
         fnd_msg_pub.ADD;

         IF l_return_status = 'S' THEN
            l_return_status := 'W';
         END IF;

      END IF;

      l_progress_indicator := '50';

      /**
       *  The Organization id must exist
       **/
      OPEN c_org_id;
      FETCH c_org_id INTO l_id;
      IF c_org_id%NOTFOUND THEN

         l_return_status := 'E';
         fnd_message.set_name('WMS','WMS_ORG_ID');
         fnd_msg_pub.add;

      END IF;
      CLOSE c_org_id;

      l_progress_indicator := '60';

      /**
       *  The Zone Id must be unique
       **/
      OPEN c_zone_id;
      FETCH c_zone_id INTO l_id;
      IF c_zone_id%NOTFOUND THEN

         NULL;

      ELSE

         l_return_status := 'E';
         fnd_message.set_name('WMS','WMS_ZONE_ID');
         fnd_msg_pub.ADD;

      END IF;
      CLOSE c_zone_id;

      l_progress_indicator := '70';

      /**
       *  The Zone Name must be unique in an organization
       **/
      OPEN c_zone_name;
      FETCH c_zone_name INTO l_zone_name;
      IF c_zone_name%NOTFOUND THEN

         NULL;

      ELSE

         l_return_status := 'E';
         fnd_message.set_name('INV', 'INV_ALREADY_EXISTS');
         fnd_message.set_token('ENTITY', 'Zone', FALSE);
         fnd_msg_pub.ADD;

      END IF;
      CLOSE c_zone_name;

      /**
       *  Flexfield attributes and WHO colums are not validated
       **/
      x_return_status := l_return_status;

      DEBUG('Call Success', l_module_name,0);

   EXCEPTION

      WHEN OTHERS THEN
         DEBUG('Unexpected Exception :' ||l_progress_indicator
	                                ||' : '||SQLERRM ,
               l_module_name,0);

         x_return_status := 'U';
         x_msg_data      := substrb(SQLERRM, 200);
         x_msg_count     := 1;

   END validate_row;


   PROCEDURE add_locators(
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_data          OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      p_zone_id           IN         NUMBER,
      p_organization_id   IN         NUMBER,
      p_subinventory_code IN         VARCHAR,
      p_locator_id        IN         NUMBER,
      p_entire_sub_flag   IN         VARCHAR,
      p_creation_date     IN         DATE,
      p_created_by        IN         NUMBER,
      p_last_update_date  IN         DATE,
      p_last_updated_by   IN         NUMBER,
      p_last_update_login IN         NUMBER
      ) IS

      l_module_name        VARCHAR2(20) := 'ADD_LOCATORS';
      l_progress_indicator VARCHAR2(20) := '0';
      l_debug              NUMBER       := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

   BEGIN

      DEBUG('In procedure :', l_module_name,0);

      IF l_debug > 0 THEN

         DEBUG('p_zone_id => '||p_zone_id, l_module_name, 9);
         DEBUG('p_organization_id => '||p_organization_id, l_module_name, 9);
         DEBUG('p_subinventory_code => '||p_subinventory_code, l_module_name, 9);
         DEBUG('p_locator_id => '||p_locator_id, l_module_name, 9);
         DEBUG('p_entire_sub_flag => '||p_entire_sub_flag, l_module_name, 9);
         DEBUG (' p_creation_date==> ' || p_creation_date,
                l_module_name, 9);
         DEBUG (' p_last_update_date==> ' || p_last_update_date,
                l_module_name, 9);
         DEBUG (' created_by==> ' || p_created_by, l_module_name, 9);
         DEBUG (' p_last_update_login==> ' || p_last_update_login,
                l_module_name, 9);
         DEBUG (' p_last_updated_by==> ' || p_last_updated_by,
                l_module_name, 9);

      END IF; /* debug > 0 */

      l_progress_indicator := '10';

      DELETE wms_zone_locators
      WHERE  zone_id = p_zone_id
      AND    organization_id = p_organization_id
      AND    subinventory_code = p_subinventory_code
      AND    NVL(p_entire_sub_flag, 'N') = 'Y';

      IF l_debug > 0 THEN
         DEBUG('Records deleted :'||SQL%ROWCOUNT, l_module_name,0);
      END IF;

      l_progress_indicator := '20';

      INSERT INTO wms_zone_locators(
                    organization_id
                  , zone_id
                  , inventory_location_id
                  , subinventory_code
                  , entire_sub_flag
                  , last_update_date
                  , last_updated_by
                  , creation_date
                  , created_by
                  , last_update_login
                                     )
                                     (
          SELECT    p_organization_id
                  , p_zone_id
                  , DECODE(p_entire_sub_flag, 'Y', NULL, p_locator_id)
                  , p_subinventory_code
                  , p_entire_sub_flag
                  , p_last_update_date
                  , p_last_updated_by
                  , p_creation_date
                  , p_created_by
                  , p_last_update_login
          FROM      dual
          WHERE NOT EXISTS (
                  SELECT 1
                  FROM   wms_zone_locators
                  WHERE  zone_id = p_zone_id
                  AND    organization_id = p_organization_id
                  AND    subinventory_code = p_subinventory_code
                  AND    entire_sub_flag = 'Y'
                           )
          AND   NOT EXISTS (
                  SELECT 1
                  FROM   wms_zone_locators
                  WHERE  zone_id = p_zone_id
                  AND    organization_id = p_organization_id
                  AND    subinventory_code = p_subinventory_code
                  AND    NVL(entire_sub_flag,'N') = 'N'
                  AND    inventory_location_id = p_locator_id
                           )
                                      );

      IF l_debug > 0 THEN
         DEBUG('Records inserted :'||SQL%ROWCOUNT, l_module_name,0);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      DEBUG('Call Success', l_module_name,0);

   EXCEPTION

      WHEN OTHERS THEN
         DEBUG('Unexpected Exception :' ||l_progress_indicator
	                                ||' : '||SQLERRM ,
               l_module_name,0);

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substrb(SQLERRM, 200);
         x_msg_count     := 1;

   END add_locators;

   PROCEDURE validate_locators(
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_data          OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      p_zone_id           IN         NUMBER,
      p_organization_id   IN         NUMBER,
      p_subinventory_code IN         VARCHAR,
      p_locator_id        IN         NUMBER,
      p_entire_sub_flag   IN         VARCHAR,
      p_creation_date     IN         DATE,
      p_created_by        IN         NUMBER,
      p_last_update_date  IN         DATE,
      p_last_updated_by   IN         NUMBER,
      p_last_update_login IN         NUMBER
      ) IS

      l_module_name        VARCHAR2(20) := 'VALIDATE_LOCATORS';
      l_progress_indicator VARCHAR2(20) := '0';
      l_debug              NUMBER       := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);
      l_return_status      VARCHAR2(1);

      l_id                 VARCHAR2(30);

      CURSOR c_org_id IS
      SELECT 1
      FROM   mtl_parameters
      WHERE  organization_id = p_organization_id;

      CURSOR c_zone_id IS
      SELECT 1
      FROM   wms_zones_b
      WHERE  zone_id = p_zone_id;

      CURSOR c_subinventory_code IS
      SELECT 1
      FROM   mtl_secondary_inventories
      WHERE  organization_id = p_organization_id
      AND    secondary_inventory_name = p_subinventory_code;

      CURSOR c_locator_id IS
      SELECT 1
      FROM   mtl_item_locations
      WHERE  inventory_location_id = p_locator_id
      AND    organization_id = p_organization_id
      AND    subinventory_code = p_subinventory_code;

   BEGIN

      DEBUG('In procedure :', l_module_name,0);

      IF l_debug > 0 THEN

         DEBUG('p_zone_id => '||p_zone_id, l_module_name, 9);
         DEBUG('p_organization_id => '||p_organization_id, l_module_name, 9);
         DEBUG('p_subinventory_code => '||p_subinventory_code, l_module_name, 9);
         DEBUG('p_locator_id => '||p_locator_id, l_module_name, 9);
         DEBUG('p_entire_sub_flag => '||p_entire_sub_flag, l_module_name, 9);
         DEBUG (' p_creation_date==> ' || p_creation_date,
                l_module_name, 9);
         DEBUG (' p_last_update_date==> ' || p_last_update_date,
                l_module_name, 9);
         DEBUG (' created_by==> ' || p_created_by, l_module_name, 9);
         DEBUG (' p_last_update_login==> ' || p_last_update_login,
                l_module_name, 9);
         DEBUG (' p_last_updated_by==> ' || p_last_updated_by,
                l_module_name, 9);

      END IF; /* debug > 0 */

      l_progress_indicator := '10';

      /**
       *  p_entire_sub_flag can be 'Y', 'N' or NULL,
       *  Value of NULL is same as 'N'
       */
      IF p_entire_sub_flag IS NULL OR
         p_entire_sub_flag = 'Y' OR
         p_entire_sub_flag = 'N' THEN

         NULL;

      ELSE

         l_return_status := fnd_api.g_ret_sts_error;

      END IF;

      l_progress_indicator := '20';

      /**
       *  If p_entire_sub_flag = 'Y' then p_locator_id
       *  MUST be NULL
       */
      IF p_entire_sub_flag = 'Y' AND p_locator_id IS NOT NULL THEN

         l_return_status := fnd_api.g_ret_sts_error;

      END IF;

      l_progress_indicator := '30';

      /**
       *  p_organization_id must exist in MTL_PARAMETERS
       */
      OPEN c_org_id;
      FETCH c_org_id INTO l_id;
      IF c_org_id%NOTFOUND THEN
         l_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_org_id;

      l_progress_indicator := '40';

      /**
       *  p_zone_id must exist in WMS_ZONES_B
       */
      OPEN c_zone_id;
      FETCH c_zone_id INTO l_id;
      IF c_zone_id%NOTFOUND THEN
         l_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_zone_id;

      l_progress_indicator := '50';

      /**
       *  p_subinventory_code must exist in for that
       *  p_organization_id in MTL_SECONDARY_INVENTORIES
       */
      OPEN c_subinventory_code;
      FETCH c_subinventory_code INTO l_id;
      IF c_subinventory_code%NOTFOUND THEN
         l_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_subinventory_code;

      l_progress_indicator := '60';

      /**
       *  If p_entire_sub_flag IS 'Y', then p_locator_id must
       *  be null, this is validated above.
       *
       *  However if p_entire_sub_flag is NULL or N then
       *  p_locator_id must exist in the p_subinventory_code/
       *  p_organization_id in MTL_ITEM_LOCATIONS
       */
      IF NVL(p_entire_sub_flag, 'N') = 'N' THEN

         OPEN c_locator_id;
         FETCH c_locator_id INTO l_id;
         IF c_locator_id%NOTFOUND THEN
            l_return_status := fnd_api.g_ret_sts_error;
         END IF;
         CLOSE c_locator_id;

      END IF;

      /**
       *  WHO colums are not validated
       **/
      x_return_status := l_return_status;

      DEBUG('Call Success', l_module_name,0);

   EXCEPTION

      WHEN OTHERS THEN
         DEBUG('Unexpected Exception :' ||l_progress_indicator
	                                ||' : '||SQLERRM ,
               l_module_name,0);

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substrb(SQLERRM, 200);
         x_msg_count     := 1;

   END validate_locators;

   PROCEDURE delete_locators(
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_data          OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      p_zone_id           IN         NUMBER,
      p_organization_id   IN         NUMBER,
      p_subinventory_code IN         VARCHAR,
      p_locator_id        IN         NUMBER,
      p_entire_sub_flag   IN         VARCHAR
      ) IS

      l_module_name        VARCHAR2(20) := 'DELETE_LOCATORS';
      l_progress_indicator VARCHAR2(20) := '0';
      l_debug              NUMBER       := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

   BEGIN

      DEBUG('In procedure :', l_module_name,0);

      IF l_debug > 0 THEN

         DEBUG('p_zone_id => '||p_zone_id, l_module_name, 9);
         DEBUG('p_organization_id => '||p_organization_id, l_module_name, 9);
         DEBUG('p_subinventory_code => '||p_subinventory_code, l_module_name, 9);
         DEBUG('p_locator_id => '||p_locator_id, l_module_name, 9);
         DEBUG('p_entire_sub_flag => '||p_entire_sub_flag, l_module_name, 9);

      END IF;

      l_progress_indicator := '10';

      DELETE wms_zone_locators
      WHERE  zone_id = p_zone_id
      AND    organization_id = p_organization_id
      AND    subinventory_code = p_subinventory_code
      AND    ( (p_entire_sub_flag = 'Y') OR (
                nvl(p_entire_sub_flag,'N') = 'N' AND
                inventory_location_id = p_locator_id ) );

      IF l_debug > 0 THEN
         DEBUG('Deleted Rows : '||SQL%ROWCOUNT, l_module_name, 9);
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      DEBUG('Call Success', l_module_name,0);

   EXCEPTION

      WHEN OTHERS THEN
         DEBUG('Unexpected Exception :' ||l_progress_indicator
	                                ||' : '||SQLERRM ,
               l_module_name,0);

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substrb(SQLERRM, 200);
         x_msg_count     := 1;

   END delete_locators;

END wms_zones_pvt;

/

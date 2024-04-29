--------------------------------------------------------
--  DDL for Package Body WMS_LPN_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LPN_LOVS" AS
/* $Header: WMSLPNLB.pls 120.7.12010000.12 2013/03/01 07:01:11 ssingams ship $ */

--      Name: GET_LPN_LOV
--
--      Input parameters:
--       p_lpn   which restricts LOV SQL to the user input text
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid LPN and lpn_id
--


PROCEDURE mydebug(msg in varchar2)
  IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
--   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
--   l_msg:=l_ts||'  '||msg;

   l_msg := msg;

   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'WMS_LPN_LOVS',
      p_level => 4);

   --dbms_output.put_line(l_msg);
END;

PROCEDURE GET_SOURCE_LOV
  (x_source_lov  OUT  NOCOPY t_genref,
   p_lookup_type IN   VARCHAR2
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_source_lov FOR
     SELECT meaning, lookup_code
     FROM mfg_lookups
     WHERE lookup_type = 'WMS_PREPACK_SOURCE'
     AND meaning LIKE (p_lookup_type)
     ORDER BY lookup_code;

END get_source_lov;



PROCEDURE GET_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_lpn_lov FOR
     SELECT license_plate_number,
            lpn_id,
            NVL(inventory_item_id, 0),
            NVL(organization_id, 0),
            revision,
            lot_number,
            serial_number,
            subinventory_code,
            NVL(locator_id, 0),
            NVL(parent_lpn_id, 0),
            NVL(sealed_status, 2),
            gross_weight_uom_code,
            NVL(gross_weight, 0),
            content_volume_uom_code,
            NVL(content_volume, 0)
     FROM wms_license_plate_numbers
     WHERE license_plate_number LIKE (p_lpn)
     ORDER BY license_plate_number;

END GET_LPN_LOV;

PROCEDURE GET_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
    p_lpn      IN   VARCHAR2,
    p_orgid  IN VARCHAR2
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_lpn_lov FOR
     SELECT license_plate_number,
            lpn_id,
            NVL(inventory_item_id, 0),
            NVL(organization_id, 0),
            revision,
            lot_number,
            serial_number,
            subinventory_code,
            NVL(locator_id, 0),
            NVL(parent_lpn_id, 0),
            NVL(sealed_status, 2),
            gross_weight_uom_code,
            NVL(gross_weight, 0),
            content_volume_uom_code,
            NVL(content_volume, 0)
     FROM wms_license_plate_numbers
     WHERE license_plate_number LIKE (p_lpn)
     and organization_id LIKE (p_orgid)
     ORDER BY license_plate_number;

END GET_LPN_LOV;


PROCEDURE GET_LABEL_PICK_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_org_id   IN   NUMBER,
   p_sub_code IN   VARCHAR2 DEFAULT NULL
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_lpn_lov FOR
     SELECT distinct wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlpn.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            wlpn.subinventory_code,
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
     FROM wms_license_plate_numbers wlpn,
          mtl_material_transactions_temp mmtt
     WHERE wlpn.license_plate_number LIKE (p_lpn) and
           mmtt.organization_id = p_org_id  and
           mmtt.cartonization_id = wlpn.lpn_id and
           mmtt.subinventory_code = nvl(p_sub_code, mmtt.subinventory_code)
     ORDER BY license_plate_number;

END GET_LABEL_PICK_LPN_LOV;

-- This LOV has been deprecated because it uses dynamic SQL. Please create
-- a NEW LOV if you need to use this

PROCEDURE GET_WHERE_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_where_clause      IN   VARCHAR2
)
IS
  l_sql_stmt VARCHAR2(4000) :=
     'SELECT DISTINCT wlpn.license_plate_number, ' ||
     '      wlpn.lpn_id, ' ||
     '      NVL(wlpn.inventory_item_id, 0), ' ||
     '      NVL(wlpn.organization_id, 0), ' ||
     '      wlpn.revision, ' ||
     '      wlpn.lot_number, ' ||
     '      wlpn.serial_number, ' ||
     '      wlpn.subinventory_code, ' ||
     '      NVL(wlpn.locator_id, 0), ' ||
     '      NVL(wlpn.parent_lpn_id, 0), ' ||
     '      NVL(wlpn.sealed_status, 2), ' ||
     '      wlpn.gross_weight_uom_code, ' ||
     '      NVL(wlpn.gross_weight, 0), ' ||
     '      wlpn.content_volume_uom_code, ' ||
     '      NVL(wlpn.content_volume, 0), ' ||
     '      milk.concatenated_segments, ' ||
     '      wlpn.lpn_context           ' ||
     'FROM  wms_license_plate_numbers wlpn, ' ||
     '      mtl_item_locations_kfv milk, ' ||
     '      wms_lpn_contents wlc ' ||
     'WHERE wlpn.organization_id = milk.organization_id (+) ' ||
     '  AND wlpn.locator_id = milk.inventory_location_id(+) ' ||
     '  AND wlc.parent_lpn_id (+) = wlpn.lpn_id ';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_sql_stmt := l_sql_stmt ||
                'AND wlpn.license_plate_number LIKE :p_lpn ' ||
                p_where_clause;
   --dbms_output.put_line( length(l_sql_stmt) );
   --dbms_output.put_line( Substr(l_sql_stmt, 1, 255) );
   --dbms_output.put_line( Substr(l_sql_stmt, 256, 255));
   --dbms_output.put_line( Substr(l_sql_stmt, 512, 255));
   OPEN x_lpn_lov FOR l_sql_stmt USING p_lpn;
END GET_WHERE_LPN_LOV;

/*******************************************************************
        WMS - PJM Integration Enhancements
 Added a new Procedure WHERE_PJM_LPN_LOV which is similar to
 GET_WHERE_LPN_LOV. This returns the locator concatenated segments
 without the SEGMENT19 and SEGMENT20. Also it returns the Project
 and Task Information
********************************************************************/
PROCEDURE GET_WHERE_PJM_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_where_clause      IN   VARCHAR2
)
IS
  l_sql_stmt VARCHAR2(4000) :=
     'SELECT DISTINCT wlpn.license_plate_number, ' ||
     '      wlpn.lpn_id, ' ||
     '      NVL(wlpn.inventory_item_id, 0), ' ||
     '      NVL(wlpn.organization_id, 0), ' ||
     '      wlpn.revision, ' ||
     '      wlpn.lot_number, ' ||
     '      wlpn.serial_number, ' ||
     '      wlpn.subinventory_code, ' ||
     '      NVL(wlpn.locator_id, 0), ' ||
     '      NVL(wlpn.parent_lpn_id, 0), ' ||
     '      NVL(wlpn.sealed_status, 2), ' ||
     '      wlpn.gross_weight_uom_code, ' ||
     '      NVL(wlpn.gross_weight, 0), ' ||
     '      wlpn.content_volume_uom_code, ' ||
     '      NVL(wlpn.content_volume, 0), ' ||
     '      INV_PROJECT.GET_LOCSEGS(milk.inventory_location_id,milk.organization_id), ' ||
     '      INV_PROJECT.GET_PROJECT_ID, ' ||
     '      INV_PROJECT.GET_PROJECT_NUMBER, ' ||
     '      INV_PROJECT.GET_TASK_ID, ' ||
     '      INV_PROJECT.GET_TASK_NUMBER, ' ||
     '      wlpn.lpn_context           ' ||
     'FROM  wms_license_plate_numbers wlpn, ' ||
     '      mtl_item_locations milk, ' ||
     '      wms_lpn_contents wlc ' ||
     'WHERE wlpn.organization_id = milk.organization_id (+) ' ||
     '  AND wlpn.locator_id = milk.inventory_location_id(+) ' ||
     '  AND wlc.parent_lpn_id (+) = wlpn.lpn_id ';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (l_debug = 1) THEN
      inv_log_util.trace('In Get_WHERE_PJM_LPN_LOV', 'WMS_LPN_LOVs',1);
   END IF;
   l_sql_stmt := l_sql_stmt ||
                'AND wlpn.license_plate_number LIKE :p_lpn ' ||
                p_where_clause;
   OPEN x_lpn_lov FOR l_sql_stmt USING p_lpn;
END GET_WHERE_PJM_LPN_LOV;


PROCEDURE GET_PUTAWAY_WHERE_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id IN VARCHAR2
   )
  IS

     l_lpn VARCHAR2(50);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_lpn := p_lpn;

   OPEN x_lpn_lov FOR

     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv          milk,
     wms_lpn_contents                wlc
     WHERE wlpn.organization_id = To_number(p_organization_id)
     AND wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND wlpn.lpn_context < 4
     AND wlpn.license_plate_number LIKE l_lpn
     ORDER BY wlpn.license_plate_number;

END GET_PUTAWAY_WHERE_LPN_LOV;


PROCEDURE GET_PICK_LOAD_TO_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2
)
IS

   l_lpn VARCHAR2(50);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_lpn := p_lpn;
   OPEN x_lpn_lov FOR

     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv          milk,
     wms_lpn_contents                wlc
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND (lpn_context = 8 OR lpn_context = 5)
     AND wlpn.license_plate_number LIKE l_lpn
     ORDER BY wlpn.license_plate_number;

END GET_PICK_LOAD_TO_LPN_LOV;

PROCEDURE validate_pick_load_to_lpn
       (p_tolpn      IN   VARCHAR2,
        x_is_valid_tolpn  OUT NOCOPY VARCHAR2,
        x_tolpn_id        OUT NOCOPY NUMBER
        )
IS
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

     TYPE tolpn_record_type IS RECORD
         (tolpn                    VARCHAR2(30),
          tolpn_id                 NUMBER,
          tolpn_inventory_item_id  NUMBER,
          organization_id          NUMBER,
          revision                 VARCHAR2(3),
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
          lot_number               VARCHAR2(80),
          serial_number            VARCHAR2(30),
          subinventory_code        VARCHAR2(10),
          locator_id               NUMBER,
          parent_lpn_id            NUMBER,
          sealed_status            NUMBER,
          gross_weight_uom_code    VARCHAR2(3),
          gross_weight             NUMBER,
          content_volume_uom_code  VARCHAR2(3),
          content_volume           NUMBER,
          concatenated_segments    VARCHAR2(30),
          lpn_context              NUMBER);


        tolpn_rec      tolpn_record_type;
        l_tolpns       t_genref;

BEGIN
        x_is_valid_tolpn := 'N';
        get_pick_load_to_lpn_lov( x_lpn_lov  => l_tolpns,
                                  p_lpn      => p_tolpn);
        LOOP
              FETCH l_tolpns INTO tolpn_rec;
              EXIT WHEN l_tolpns%notfound;

              IF tolpn_rec.tolpn = p_tolpn THEN
                 x_is_valid_tolpn := 'Y';
                 x_tolpn_id := tolpn_rec.tolpn_id;
                 EXIT;
              END IF;

        END LOOP;

END validate_pick_load_to_lpn;

/* BUG#2905646 Added Project and Task to show LPN's belonging to Project and Tasks in From LPN for PJM Org's. */
PROCEDURE GET_PICK_LOAD_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_cost_group_id IN NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_locator_id IN NUMBER,
   p_project_id IN   NUMBER := NULL,
   p_task_id    IN   NUMBER := NULL
)
  IS

    l_lpn VARCHAR2(50);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

   l_lpn := p_lpn;

   OPEN x_lpn_lov FOR

     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
           mtl_item_locations_kfv          milk,
           wms_lpn_contents                wlc
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
     --AND wlc.cost_group_id         = nvl(l_cost_group_id, wlc.cost_group_id)
     AND wlpn.subinventory_code    = p_subinventory_code
     AND wlpn.locator_id           = p_locator_id
     -- PJM changes: Bug 2774506/2905646 : Added project_id and task_id to show LPN's belonging to PJM locators.
     AND ( wlpn.locator_id IS NULL OR
                wlpn.locator_id IN
               (SELECT DISTINCT mil.inventory_location_id
               FROM   mtl_item_locations mil
               WHERE  NVL(mil.project_id, -1) = NVL(p_project_id, -1)
               AND    NVL(mil.task_id, -1)    = NVL(p_task_id, -1))
          )
     ORDER BY wlpn.license_plate_number;


END GET_PICK_LOAD_LPN_LOV;

PROCEDURE GET_ALL_APL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_project_id IN   NUMBER := NULL,
   p_task_id    IN   NUMBER := NULL
)
  IS

    l_lpn VARCHAR2(50);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

   l_lpn := p_lpn;

   OPEN x_lpn_lov FOR

     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
           mtl_item_locations_kfv          milk,
           wms_lpn_contents                wlc
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
     AND ( wlpn.locator_id IS NULL OR
                wlpn.locator_id IN
               (SELECT DISTINCT mil.inventory_location_id
               FROM   mtl_item_locations mil
               WHERE  NVL(mil.project_id, -1) = NVL(p_project_id, -1)
               AND    NVL(mil.task_id, -1)    = NVL(p_task_id, -1))
          )
     ORDER BY wlpn.license_plate_number;


END GET_ALL_APL_LPN_LOV;

PROCEDURE GET_SUB_APL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_project_id IN   NUMBER := NULL,
   p_task_id    IN   NUMBER := NULL
)
  IS

    l_lpn VARCHAR2(50);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

   l_lpn := p_lpn;

   OPEN x_lpn_lov FOR

     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
           mtl_item_locations_kfv          milk,
           wms_lpn_contents                wlc
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
     AND wlpn.subinventory_code    = p_subinventory_code
     AND ( wlpn.locator_id IS NULL OR
                wlpn.locator_id IN
               (SELECT DISTINCT mil.inventory_location_id
               FROM   mtl_item_locations mil
               WHERE  NVL(mil.project_id, -1) = NVL(p_project_id, -1)
               AND    NVL(mil.task_id, -1)    = NVL(p_task_id, -1))
          )
     ORDER BY wlpn.license_plate_number;

END GET_SUB_APL_LPN_LOV;

PROCEDURE validate_pick_load_lpn_lov
      (p_fromlpn             IN     VARCHAR2,
       p_organization_id     IN     NUMBER,
       p_revision            IN     VARCHAR2,
       p_inventory_item_id   IN     NUMBER,
       p_cost_group_id       IN     NUMBER,
       p_subinventory_code   IN     VARCHAR2,
       p_locator_id          IN     NUMBER,
       p_project_id          IN     NUMBER := NULL,
       p_task_id             IN     NUMBER := NULL,
       p_transaction_temp_id IN     NUMBER,
       p_serial_allocated    IN     VARCHAR2,
       x_is_valid_fromlpn  OUT    NOCOPY  VARCHAR2,
       x_fromlpn_id        OUT    NOCOPY  NUMBER)

IS
     TYPE fromlpn_record_type IS RECORD
          (license_plate_number    VARCHAR2(30),
           lpn_id                  NUMBER,
           inventory_item_id       NUMBER,
           organization_id         NUMBER,
           revision                VARCHAR2(3),
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
           lot_number              VARCHAR2(80),
           serial_number           VARCHAR2(30),
           subinventory_code       VARCHAR2(10),
           locator_id              NUMBER,
           parent_lpn_id           NUMBER,
           sealed_status           NUMBER,
           gross_weight_uom_code   VARCHAR2(3),
           gross_weight            NUMBER,
           content_volume_uom_code VARCHAR2(3),
           content_volume          NUMBER,
           concatenated_segments   VARCHAR2(204),
           lpn_context             NUMBER);

        fromlpn_rec      fromlpn_record_type;
        l_fromlpns       t_genref;
        l_project_id     NUMBER;
        l_task_id        NUMBER;

BEGIN

        x_is_valid_fromlpn := 'N';

        IF p_project_id IS NOT NULL THEN
           IF p_project_id = 0 THEN
              l_project_id := NULL;
           END IF;
        ELSE
           l_project_id := NULL;
        END IF;

        IF p_task_id IS NOT NULL THEN
           IF p_task_id = 0 THEN
              l_task_id := NULL;
           END IF;
        ELSE
           l_task_id := NULL;
        END IF;

        IF p_serial_allocated = 'Y' THEN

              GET_PICK_LOAD_SERIAL_LPN_LOV
                (x_lpn_lov             => l_fromlpns,
                 p_lpn                 => p_fromlpn,
                 p_organization_id     => p_organization_id,
                 p_revision            => p_revision,
                 p_inventory_item_id   => p_inventory_item_id,
                 p_cost_group_id       => p_cost_group_id,
                 p_subinventory_code   => p_subinventory_code,
                 p_locator_id          => p_locator_id,
                 p_transaction_temp_id => p_transaction_temp_id);

        ELSE
              GET_PICK_LOAD_LPN_LOV
                (x_lpn_lov           => l_fromlpns,
                 p_lpn               => p_fromlpn,
                 p_organization_id   => p_organization_id,
                 p_revision          => p_revision,
                 p_inventory_item_id => p_inventory_item_id,
                 p_cost_group_id     => p_cost_group_id,
                 p_subinventory_code => p_subinventory_code,
                 p_locator_id        => p_locator_id,
                 p_project_id        => l_project_id,
                 p_task_id           => l_task_id);
        END IF;


        LOOP
              FETCH l_fromlpns INTO fromlpn_rec;
              EXIT WHEN l_fromlpns%notfound;

              IF fromlpn_rec.license_plate_number = p_fromlpn THEN
                 x_is_valid_fromlpn := 'Y';
                 x_fromlpn_id := fromlpn_rec.lpn_id;
                 EXIT;
              END IF;

       END LOOP;

END validate_pick_load_lpn_lov;


PROCEDURE GET_PICK_DROP_LPN_LOV
( x_lpn_lov         OUT NOCOPY  t_genref
, p_lpn             IN          VARCHAR2
, p_pick_to_lpn_id  IN          NUMBER
, p_org_id          IN          NUMBER
, p_drop_sub        IN          VARCHAR2
, p_drop_loc        IN          NUMBER
)
  -- passed p_drop_sub and p_drop_loc --vipartha
IS
   l_lpn    VARCHAR2(50);
   l_debug  NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

   IF p_lpn IS NOT NULL then
      l_lpn := p_lpn;
    ELSE
      l_lpn := '%';
   END IF;

   OPEN x_lpn_lov FOR
     SELECT DISTINCT wlpn.license_plate_number
             , wlpn.lpn_id
             , NVL(wlpn.inventory_item_id, 0)
             , NVL(wlpn.organization_id, 0)
             , wlpn.revision
             , wlpn.lot_number
             , wlpn.serial_number
             , wlpn.subinventory_code
	     , NVL(wlpn.locator_id, 0)
             , NVL(wlpn.parent_lpn_id, 0)
             , NVL(wlpn.sealed_status, 2)
             , wlpn.gross_weight_uom_code
             , NVL(wlpn.gross_weight, 0)
             , wlpn.content_volume_uom_code
             , NVL(wlpn.content_volume, 0)
             , milk.concatenated_segments
             , wlpn.lpn_context
          FROM wms_license_plate_numbers  wlpn
             , mtl_item_locations_kfv     milk
        WHERE wlpn.organization_id   = milk.organization_id       (+)
          AND wlpn.locator_id        = milk.inventory_location_id (+)
          AND wlpn.outermost_lpn_id  = wlpn.lpn_id
          AND wlpn.lpn_context       = 11
          AND wlpn.subinventory_code = p_drop_sub
          AND wlpn.locator_id        = p_drop_loc
          AND wlpn.license_plate_number LIKE l_lpn
          AND WMS_task_dispatch_gen.validate_pick_drop_lpn
              ( 1.0
              , 'F'
              , p_pick_to_lpn_id
              , p_org_id
              , wlpn.license_plate_number
              , p_drop_sub
              , p_drop_loc
              ) = 1
        ORDER BY license_plate_number;

END GET_PICK_DROP_LPN_LOV;


-- This LOV has been deprecated because it uses dynamic SQL. Please create
-- a NEW LOV if you need to use this

PROCEDURE GET_WHERE_SERIAL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_where_clause      IN   VARCHAR2
   )
  IS
     l_sql_stmt VARCHAR2(4000) :=
       'SELECT DISTINCT wlpn.license_plate_number, ' ||
       '      wlpn.lpn_id, ' ||
       '      NVL(wlpn.inventory_item_id, 0), ' ||
       '      NVL(wlpn.organization_id, 0), ' ||
       '      wlpn.revision, ' ||
       '      wlpn.lot_number, ' ||
       '      wlpn.serial_number, ' ||
       '      wlpn.subinventory_code, ' ||
       '      NVL(wlpn.locator_id, 0), ' ||
       '      NVL(wlpn.parent_lpn_id, 0), ' ||
       '      NVL(wlpn.sealed_status, 2), ' ||
       '      wlpn.gross_weight_uom_code, ' ||
       '      NVL(wlpn.gross_weight, 0), ' ||
       '      wlpn.content_volume_uom_code, ' ||
       '      NVL(wlpn.content_volume, 0), ' ||
       '      milk.concatenated_segments, ' ||
       '      wlpn.lpn_context           ' ||
       'FROM  wms_license_plate_numbers wlpn, ' ||
       '      mtl_item_locations_kfv milk, ' ||
       '      wms_lpn_contents wlc, ' ||
       '      mtl_serial_numbers msn, ' ||
       '      mtl_serial_numbers_temp msnt ' ||
       'WHERE wlpn.organization_id = milk.organization_id (+) ' ||
       '  AND wlpn.locator_id = milk.inventory_location_id(+) ' ||
       '  AND wlc.parent_lpn_id (+) = wlpn.lpn_id ' ||
       '  AND msn.serial_number = msnt.fm_serial_number ' ||
       '  AND msn.lpn_id = wlpn.lpn_id ';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_sql_stmt := l_sql_stmt ||
     ' AND wlpn.license_plate_number LIKE :p_lpn ' ||
     p_where_clause;

   OPEN x_lpn_lov FOR l_sql_stmt USING p_lpn;
END GET_WHERE_SERIAL_LPN_LOV;


PROCEDURE GET_PICK_LOAD_SERIAL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_cost_group_id IN NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_locator_id IN NUMBER,
   p_transaction_temp_id IN NUMBER
   )
  IS

     l_lpn VARCHAR2(50);
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_lpn := p_lpn;

   OPEN x_lpn_lov FOR

     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv          milk,
     wms_lpn_contents                wlc,
     mtl_serial_numbers              msn,
     mtl_serial_numbers_temp         msnt
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND msn.serial_number         = msnt.fm_serial_number
     AND msn.lpn_id                = wlpn.lpn_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
    -- AND wlc.cost_group_id         = nvl(l_cost_group_id, wlc.cost_group_id)  --bug 2748240
     AND wlpn.subinventory_code    = p_subinventory_code
     AND wlpn.locator_id           = p_locator_id
     AND msnt.transaction_temp_id  = p_transaction_temp_id
      UNION
     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv          milk,
     wms_lpn_contents                wlc,
     mtl_serial_numbers              msn,
     mtl_serial_numbers_temp         msnt,
     mtl_transaction_lots_temp       mtlt,
     mtl_material_transactions_temp  mmtt
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND msn.serial_number         = msnt.fm_serial_number
     AND msn.lpn_id                = wlpn.lpn_id
     AND mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
     AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
    -- AND wlc.cost_group_id         = nvl(l_cost_group_id, wlc.cost_group_id) --  bug 2748240
     AND wlpn.subinventory_code    = p_subinventory_code
     AND wlpn.locator_id           = p_locator_id
     AND mmtt.transaction_temp_id  = p_transaction_temp_id
     ORDER BY license_plate_number;

END GET_PICK_LOAD_SERIAL_LPN_LOV;


-- Bug 3452436 : Added for patchset J project Advanced Pick Load.
-- This LOV fetches all the LPN in the given Org, containing the givn Item
-- and allocated serials
PROCEDURE GET_ALL_APL_SERIAL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_transaction_temp_id IN NUMBER
   )
  IS

     l_lpn VARCHAR2(50);
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_lpn := p_lpn;

   OPEN x_lpn_lov FOR

     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv          milk,
     wms_lpn_contents                wlc,
     mtl_serial_numbers              msn,
     mtl_serial_numbers_temp         msnt
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND msn.serial_number         = msnt.fm_serial_number
     AND msn.lpn_id                = wlpn.lpn_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
     AND msnt.transaction_temp_id  = p_transaction_temp_id
      UNION
     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv          milk,
     wms_lpn_contents                wlc,
     mtl_serial_numbers              msn,
     mtl_serial_numbers_temp         msnt,
     mtl_transaction_lots_temp       mtlt,
     mtl_material_transactions_temp  mmtt
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND msn.serial_number         = msnt.fm_serial_number
     AND msn.lpn_id                = wlpn.lpn_id
     AND mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
     AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
     AND mmtt.transaction_temp_id  = p_transaction_temp_id
     ORDER BY license_plate_number;

END GET_ALL_APL_SERIAL_LPN_LOV;

-- Bug 3452436 : Added for patchset J project Advanced Pick Load.
-- This LOV fetches all the LPN in the given Org, sub, containing the givn Item
-- and allocated serials
PROCEDURE GET_SUB_APL_SERIAL_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id  IN NUMBER,
   p_revision  IN VARCHAR2,
   p_inventory_item_id IN NUMBER,
   p_subinventory_code IN VARCHAR2,
   p_transaction_temp_id IN NUMBER
   )
  IS

     l_lpn VARCHAR2(50);
     l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_lpn := p_lpn;

   OPEN x_lpn_lov FOR

     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv          milk,
     wms_lpn_contents                wlc,
     mtl_serial_numbers              msn,
     mtl_serial_numbers_temp         msnt
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND msn.serial_number         = msnt.fm_serial_number
     AND msn.lpn_id                = wlpn.lpn_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
     AND wlpn.subinventory_code    = p_subinventory_code
     AND msnt.transaction_temp_id  = p_transaction_temp_id
      UNION
     SELECT  DISTINCT wlpn.license_plate_number,
     wlpn.lpn_id,
     NVL(wlpn.inventory_item_id, 0),
     NVL(wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL(wlpn.locator_id, 0),
     NVL(wlpn.parent_lpn_id, 0),
     NVL(wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL(wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL(wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
     FROM  wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv          milk,
     wms_lpn_contents                wlc,
     mtl_serial_numbers              msn,
     mtl_serial_numbers_temp         msnt,
     mtl_transaction_lots_temp       mtlt,
     mtl_material_transactions_temp  mmtt
     WHERE wlpn.organization_id    = milk.organization_id (+)
     AND wlpn.locator_id           = milk.inventory_location_id(+)
     AND wlc.parent_lpn_id (+)     = wlpn.lpn_id
     AND msn.serial_number         = msnt.fm_serial_number
     AND msn.lpn_id                = wlpn.lpn_id
     AND mtlt.serial_transaction_temp_id = msnt.transaction_temp_id
     AND mmtt.transaction_temp_id = mtlt.transaction_temp_id
     AND wlpn.license_plate_number LIKE l_lpn
     AND lpn_context               = 1
     AND wlpn.organization_id      = p_organization_id
     AND Nvl(wlc.revision, '-999') = Nvl(p_revision, '-999')
     AND wlc.inventory_item_id     = p_inventory_item_id
     AND wlpn.subinventory_code    = p_subinventory_code
     AND mmtt.transaction_temp_id  = p_transaction_temp_id
     ORDER BY license_plate_number;

END GET_SUB_APL_SERIAL_LPN_LOV;




PROCEDURE GET_PHYINV_PARENT_LPN_LOV
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_dynamic_entry_flag     IN   NUMBER    ,
   p_physical_inventory_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_project_id             IN   NUMBER := NULL,
   p_task_id                IN   NUMBER := NULL
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
      -- Select all LPN's which exist in the given org, sub, loc
      OPEN x_lpn_lov FOR
 SELECT license_plate_number,
        lpn_id,
        inventory_item_id,
        organization_id,
        revision,
        lot_number,
        serial_number,
        subinventory_code,
        locator_id,
        parent_lpn_id,
        NVL(sealed_status, 2),
        gross_weight_uom_code,
        NVL(gross_weight, 0),
        content_volume_uom_code,
        NVL(content_volume, 0),
        lpn_context             -- Added for resolution of Bug# 4349304, The LPN Context is required by the LOVs called
                                -- by the Cycle Count and Physical Count pages to validate whether the LPN belongs to same
                                --organization, whether the LPN is "Issued out of Stores".
 FROM wms_license_plate_numbers
 WHERE organization_id = p_organization_id
 AND subinventory_code = p_subinventory_code
 AND lpn_context  not in ( 4,6) --Bug#4267956.Added 6
 AND Nvl(locator_id, -99999) = Nvl(p_locator_id, -99999)
-- PJM Changes
   AND ( locator_id IS NULL OR
         locator_id IN
         (SELECT DISTINCT mil.inventory_location_id
          FROM   mtl_item_locations mil
          WHERE  NVL(mil.project_id, -1) = NVL(p_project_id, -1)
          AND    NVL(mil.task_id, -1)    = NVL(p_task_id, -1))
        )
 AND license_plate_number LIKE (p_lpn)
 ORDER BY license_plate_number;
    ELSE -- Dynamic entries are not allowed
      -- Select only LPN's that exist in table MTL_PHYSICAL_INVENTORY_TAGS
      OPEN x_lpn_lov FOR
 SELECT UNIQUE wlpn.license_plate_number,
        wlpn.lpn_id,
        wlpn.inventory_item_id,
        wlpn.organization_id,
        wlpn.revision,
        wlpn.lot_number,
        wlpn.serial_number,
        wlpn.subinventory_code,
        wlpn.locator_id,
        wlpn.parent_lpn_id,
        NVL(wlpn.sealed_status, 2),
        wlpn.gross_weight_uom_code,
        NVL(wlpn.gross_weight, 0),
        wlpn.content_volume_uom_code,
        NVL(wlpn.content_volume, 0),
        wlpn.lpn_context        -- Added for resolution of Bug# 4349304. The LPN Context is required by the LOVs called
                                -- by the Cycle Count and Physical Count pages to validate whether the LPN belongs to same
                                --organization, whether the LPN is "Issued out of Stores".
 FROM wms_license_plate_numbers wlpn,
 mtl_physical_inventory_tags mpit
 WHERE wlpn.organization_id = p_organization_id
 AND wlpn.subinventory_code = p_subinventory_code
        -- Bug# 1609449
 --AND Nvl(wlpn.locator_id, -99999) = Nvl(p_locator_id, -99999)
 AND wlpn.license_plate_number LIKE (p_lpn)
 AND wlpn.lpn_id = mpit.parent_lpn_id
 AND wlpn.lpn_context  not in ( 4,6) --Bug#4267956.Added 6
 AND mpit.organization_id = p_organization_id
 AND mpit.physical_inventory_id = p_physical_inventory_id
 AND mpit.subinventory = p_subinventory_code
 AND NVL(mpit.locator_id, -99999) = NVL(p_locator_id, -99999)
-- PJM Changes
   AND ( mpit.locator_id IS NULL OR
         mpit.locator_id IN
         (SELECT DISTINCT mil.inventory_location_id
          FROM   mtl_item_locations mil
          WHERE  NVL(mil.project_id, -1) = NVL(p_project_id, -1)
          AND    NVL(mil.task_id, -1)    = NVL(p_task_id, -1))
        )
 AND NVL(mpit.void_flag, 2) = 2
 AND mpit.adjustment_id IN
 (SELECT adjustment_id
  FROM mtl_physical_adjustments
  WHERE physical_inventory_id = p_physical_inventory_id
  AND organization_id = p_organization_id
  AND approval_status IS NULL);
   END IF;

END GET_PHYINV_PARENT_LPN_LOV;


PROCEDURE GET_PHYINV_LPN_LOV
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_dynamic_entry_flag     IN   NUMBER    ,
   p_physical_inventory_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_parent_lpn_id          IN   NUMBER    ,
   p_project_id             IN   NUMBER := NULL,
   p_task_id                IN   NUMBER := NULL
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
      -- Select all LPN's which exist in the given org, sub, loc
      OPEN x_lpn_lov FOR
 SELECT license_plate_number,
        lpn_id,
        inventory_item_id,
        organization_id,
        revision,
        lot_number,
        serial_number,
        subinventory_code,
        locator_id,
        parent_lpn_id,
        NVL(sealed_status, 2),
        gross_weight_uom_code,
        NVL(gross_weight, 0),
        content_volume_uom_code,
        NVL(content_volume, 0)
        lpn_context             -- Added for resolution of Bug# 4349304. The LPN Context is required by the LOVs called
                                -- by the Cycle Count and Physical Count pages to validate whether the LPN belongs to same
                                --organization, whether the LPN is "Issued out of Stores".
 FROM wms_license_plate_numbers
 WHERE organization_id = p_organization_id
 AND subinventory_code = p_subinventory_code
 AND lpn_context  not in ( 4,6) --Bug#4267956.Added 6
 AND Nvl(locator_id, -99999) = Nvl(p_locator_id, -99999)
-- PJM Changes
   AND ( locator_id IS NULL OR
         locator_id IN
         (SELECT DISTINCT mil.inventory_location_id
          FROM   mtl_item_locations mil
          WHERE  NVL(mil.project_id, -1) = NVL(p_project_id, -1)
          AND    NVL(mil.task_id, -1)    = NVL(p_task_id, -1))
        )
 AND license_plate_number LIKE (p_lpn)
       AND parent_lpn_id = p_parent_lpn_id
 ORDER BY license_plate_number;
    ELSE -- Dynamic entries are not allowed
      -- Select only LPN's that exist in table MTL_PHYSICAL_INVENTORY_TAGS
      OPEN x_lpn_lov FOR
 SELECT UNIQUE wlpn.license_plate_number,
        wlpn.lpn_id,
        wlpn.inventory_item_id,
        wlpn.organization_id,
        wlpn.revision,
        wlpn.lot_number,
        wlpn.serial_number,
        wlpn.subinventory_code,
        wlpn.locator_id,
        wlpn.parent_lpn_id,
        NVL(wlpn.sealed_status, 2),
        wlpn.gross_weight_uom_code,
        NVL(wlpn.gross_weight, 0),
        wlpn.content_volume_uom_code,
        NVL(wlpn.content_volume, 0),
        wlpn.lpn_context             -- Added for resolution of Bug# 4349304. The LPN Context is required by the LOVs called
                                -- by the Cycle Count and Physical Count pages to validate whether the LPN belongs to same
                                --organization, whether the LPN is "Issued out of Stores".
 FROM wms_license_plate_numbers wlpn,
 mtl_physical_inventory_tags mpit
 WHERE wlpn.organization_id = p_organization_id
 AND wlpn.subinventory_code = p_subinventory_code
        -- Bug# 1609449
 -- AND Nvl(wlpn.locator_id, -99999) = Nvl(p_locator_id, -99999)
 AND wlpn.license_plate_number LIKE (p_lpn)
 AND wlpn.parent_lpn_id = p_parent_lpn_id
 AND wlpn.lpn_id = mpit.parent_lpn_id
 AND wlpn.lpn_context  not in ( 4,6) --Bug#4267956.Added 6
 AND mpit.organization_id = p_organization_id
 AND mpit.physical_inventory_id = p_physical_inventory_id
 AND mpit.subinventory = p_subinventory_code
 AND NVL(mpit.locator_id, -99999) = NVL(p_locator_id, -99999)
 AND NVL(mpit.void_flag, 2) = 2
-- PJM Changes
   AND ( mpit.locator_id IS NULL OR
         mpit.locator_id IN
         (SELECT DISTINCT mil.inventory_location_id
          FROM   mtl_item_locations mil
          WHERE  NVL(mil.project_id, -1) = NVL(p_project_id, -1)
          AND    NVL(mil.task_id, -1)    = NVL(p_task_id, -1))
        )
 AND mpit.adjustment_id IN
 (SELECT adjustment_id
  FROM mtl_physical_adjustments
  WHERE physical_inventory_id = p_physical_inventory_id
  AND organization_id = p_organization_id
  AND approval_status IS NULL);
   END IF;

END GET_PHYINV_LPN_LOV;


/********************************************************************************
                        WMS - PJM Integration Changes
 Changed the second part of the Union so that the LPNs returned are filtered
 based on the project and task IDs passed as parameters.
********************************************************************************/
PROCEDURE GET_PUTAWAY_LPN_LOV
(x_lpn_lov        OUT  NOCOPY t_genref,
 p_org_id         IN   NUMBER,
 p_sub            IN   VARCHAR2 := NULL,
 p_loc_id         IN   VARCHAR2 := NULL,
 p_orig_lpn_id    IN   VARCHAR2 := NULL,
 p_lpn            IN   VARCHAR2,
 p_project_id     IN   NUMBER   := NULL,
 p_task_id        IN   NUMBER   := NULL,
 p_lpn_context    IN   NUMBER   := NULL,
 p_rcv_sub_only   IN   NUMBER
)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   OPEN x_lpn_lov FOR
     -- Select the same LPN as the original source LPN.
     -- Note that this might not make sense for the manual/consolidated
     -- Into LPN since you can't nest an LPN into itself.  However, this LOV
     -- is also used in the Item Drop scenario where it is possible for
     -- the Into/destination LPN to be the same as the source LPN if it is
     -- the last item and you are putting the entire LPN away.
     SELECT license_plate_number,
            lpn_id,
            inventory_item_id,
            organization_id,
            revision,
            lot_number,
            serial_number,
            subinventory_code,
            locator_id,
            parent_lpn_id,
            NVL(sealed_status, 2),
            gross_weight_uom_code,
            NVL(gross_weight, 0),
            content_volume_uom_code,
            NVL(content_volume, 0)
     FROM wms_license_plate_numbers wlpn
     WHERE wlpn.organization_id = p_org_id
     AND wlpn.lpn_id = p_orig_lpn_id

     UNION

     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            wlpn.inventory_item_id,
            wlpn.organization_id,
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            wlpn.subinventory_code,
            wlpn.locator_id,
            wlpn.parent_lpn_id,
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
     FROM wms_license_plate_numbers wlpn
     --,mtl_item_locations mil
     WHERE wlpn.organization_id = p_org_id
     AND wlpn.license_plate_number LIKE (p_lpn)
     AND (wlpn.lpn_context = 5
   OR (wlpn.lpn_context = 1
       -- Include Inventory LPN's only if we allow both INV and RCV subs
       AND p_rcv_sub_only = 2
       AND NVL(p_lpn_context, 1) IN (1,2,3)
       AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
       AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
       -- Project, Task comingling check will be done
       -- in validate_into_lpn for better performance.
       --AND wlpn.locator_id = mil.inventory_location_id
       --AND NVL(mil.project_id, -1)   = NVL(p_project_id, -1)
       --AND NVL(mil.task_id, -1)      = NVL(p_task_id, -1)
       AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_orig_lpn_id), -999)
       AND inv_material_status_grp.is_status_applicable(
              'TRUE',
              NULL,
              INV_GLOBALS.G_TYPE_CONTAINER_PACK,
              NULL,
              NULL,
              p_org_id,
              NULL,
              wlpn.subinventory_code,
              wlpn.locator_id,
              NULL,
              NULL,
              'Z'
              ) = 'Y'
       AND inv_material_status_grp.is_status_applicable(
              'TRUE',
              NULL,
              INV_GLOBALS.G_TYPE_CONTAINER_PACK,
              NULL,
              NULL,
              p_org_id,
              NULL,
              wlpn.subinventory_code,
              wlpn.locator_id,
              NULL,
              NULL,
              'L'
              ) = 'Y'
              ) -- or for LPN context = 1
          OR (wlpn.lpn_context = 3
       AND NVL(p_lpn_context, -999) = 3
       AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
       AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
       -- Project, Task comingling check will be done
       -- in validate_into_lpn for better performance.
       --AND wlpn.locator_id = mil.inventory_location_id
       ) -- OR for lpn_context = 3
     )-- For AND lpn context = 5
     ORDER BY license_plate_number;
END;


--Private procedures called from GET_PKUPK_LPN_LOV
--Procedure to fetch LPNs when when transaction type is Pack/Unpack
--and the LPN Context passed is 0 (fetch LPNs with context 1 and 5)
PROCEDURE GET_PACK_INV_LPNS (x_lpn_lov        OUT  NOCOPY t_genref         ,
          p_org_id            IN   NUMBER           ,
   p_sub               IN   VARCHAR2 := NULL ,
   p_loc_id            IN   VARCHAR2 := NULL ,
   p_not_lpn_id        IN   VARCHAR2 := NULL ,
   p_parent_lpn_id     IN   VARCHAR2 := '0'  ,
   p_txn_type_id       IN   NUMBER   := 0    ,
   p_incl_pre_gen_lpn  IN   VARCHAR2 :='TRUE',
   p_lpn               IN   VARCHAR2,
   p_context       IN   NUMBER := 0,
          p_project_id        IN   nUMBER := NULL,
          p_task_id           IN   NUMBER := NULL,
	  p_mtrl_sts_check    IN   VARCHAR2 := 'Y'--Bug 3980914-Added the parameter.
    )
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_incl_pre_gen_lpn = 'TRUE' THEN
    IF (l_debug = 1) THEN
       mydebug('pack and inv; pregen=true');
    END IF;
    --Select LPNs with context "1" or "5"
   open x_lpn_lov for
   SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
         wlpn.inventory_item_id,
         wlpn.organization_id,
         wlpn.revision,
         wlpn.lot_number,
         wlpn.serial_number,
         wlpn.subinventory_code,
         wlpn.locator_id,
         wlpn.parent_lpn_id,
         NVL(wlpn.sealed_status, 2),
         wlpn.gross_weight_uom_code,
         NVL(wlpn.gross_weight, 0),
         wlpn.content_volume_uom_code,
         NVL(wlpn.content_volume, 0),
         wlpn.lpn_context                 --Added for bug#4202068.
  FROM wms_license_plate_numbers wlpn
    WHERE wlpn.organization_id = p_org_id
    AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
    AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                        NVL(wlpn.parent_lpn_id, 0))
    AND wlpn.license_plate_number LIKE (p_lpn)
    /* Bug 3980914 -For LPN's with context 5, the following condition is not required
    AND wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id ) = 'Y' */
  AND (wlpn.lpn_context = 5)
    UNION ALL
    SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
         wlpn.inventory_item_id,
         wlpn.organization_id,
         wlpn.revision,
         wlpn.lot_number,
         wlpn.serial_number,
         wlpn.subinventory_code,
         wlpn.locator_id,
         wlpn.parent_lpn_id,
         NVL(wlpn.sealed_status, 2),
         wlpn.gross_weight_uom_code,
         NVL(wlpn.gross_weight, 0),
         wlpn.content_volume_uom_code,
         NVL(wlpn.content_volume, 0),
         wlpn.lpn_context                 --Added for bug#4202068.
  FROM wms_license_plate_numbers wlpn
    WHERE wlpn.organization_id = p_org_id
    AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
    AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                      NVL(wlpn.parent_lpn_id, 0))
    AND wlpn.license_plate_number LIKE (p_lpn)
    AND wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id ) = 'Y'
    AND wlpn.lpn_context = 1
    AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
    AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
    AND ( ( p_mtrl_sts_check = 'Y' -- Bug 3980914
       AND inv_material_status_grp.is_status_applicable
             ('TRUE', NULL, p_txn_type_id, NULL,
             NULL, p_org_id, NULL, wlpn.subinventory_code,
             wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
       AND inv_material_status_grp.is_status_applicable
            ('TRUE', NULL, p_txn_type_id, NULL,
            NULL, p_org_id, NULL, wlpn.subinventory_code,
            wlpn.locator_id, NULL, NULL, 'L') = 'Y'
	)
     OR p_mtrl_sts_check = 'N'  --Bug 3980914
   )
  ORDER BY license_plate_number;
  ELSE
    IF (l_debug = 1) THEN
       mydebug('pack and inv; pregen=false');
    END IF;
    -- Select LPNs with context "1"
    open x_lpn_lov for
  SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
         wlpn.inventory_item_id,
         wlpn.organization_id,
          wlpn.revision,
         wlpn.lot_number,
         wlpn.serial_number,
         wlpn.subinventory_code,
         wlpn.locator_id,
         wlpn.parent_lpn_id,
         NVL(wlpn.sealed_status, 2),
         wlpn.gross_weight_uom_code,
         NVL(wlpn.gross_weight, 0),
         wlpn.content_volume_uom_code,
         NVL(wlpn.content_volume, 0),
         wlpn.lpn_context                 --Added for bug#4202068.
  FROM   wms_license_plate_numbers wlpn
    WHERE wlpn.organization_id = p_org_id
    AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
   AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                     NVL(wlpn.parent_lpn_id, 0))
    AND wlpn.license_plate_number LIKE (p_lpn)
    AND (wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id ) = 'Y')
   AND wlpn.lpn_context = 1
  AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
   AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
   AND ( ( p_mtrl_sts_check = 'Y' -- Bug 3980914
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, p_txn_type_id, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, p_txn_type_id, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'L') = 'Y'
	 )
    OR p_mtrl_sts_check = 'N'
    )
    --End of fix for Bug 3980914
   ORDER BY license_plate_number;
  END IF;

END GET_PACK_INV_LPNS;

--Procedure to fetch LPNs when when transaction type is Pack/Unpack
--and the LPN Context passed is 0 (fetch LPNs with context 11 and 5)
PROCEDURE GET_PACK_PICKED_LPNS(x_lpn_lov        OUT  NOCOPY t_genref         ,
   p_org_id            IN   NUMBER           ,
   p_sub               IN   VARCHAR2 := NULL ,
   p_loc_id            IN   VARCHAR2 := NULL ,
   p_not_lpn_id        IN   VARCHAR2 := NULL ,
   p_parent_lpn_id     IN   VARCHAR2 := '0'  ,
   p_txn_type_id       IN   NUMBER   := 0    ,
   p_incl_pre_gen_lpn  IN   VARCHAR2 :='TRUE',
   p_lpn               IN   VARCHAR2,
   p_context       IN   NUMBER := 0,
   p_project_id        IN   NUMBER := NULL,
   p_task_id           IN   NUMBER := NULL,
   p_mtrl_sts_check    IN   VARCHAR2 := 'Y', --Bug 3980914
   p_calling           IN   VARCHAR2 := NULL  -- Bug 7210544
     )
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_incl_pre_gen_lpn = 'TRUE' THEN
    IF (l_debug = 1) THEN
       mydebug('pack and picked; pregen=true');
    END IF;
    --Select LPNs with context "11" or "5"
   open x_lpn_lov for
    SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
         wlpn.inventory_item_id,
         wlpn.organization_id,
         wlpn.revision,
         wlpn.lot_number,
         wlpn.serial_number,
         wlpn.subinventory_code,
         wlpn.locator_id,
         wlpn.parent_lpn_id,
         NVL(wlpn.sealed_status, 2),
         wlpn.gross_weight_uom_code,
         NVL(wlpn.gross_weight, 0),
         wlpn.content_volume_uom_code,
         NVL(wlpn.content_volume, 0),
         wlpn.lpn_context                 --Added for bug#4202068.
  FROM wms_license_plate_numbers wlpn
    WHERE wlpn.organization_id = p_org_id
    AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
    AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                  NVL(wlpn.parent_lpn_id, 0))
    AND wlpn.license_plate_number LIKE (p_lpn)
    /* Bug 3980914 - For LPN's with context 5, no check for subinventory required.
    AND wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id ) = 'Y' */
  AND (wlpn.lpn_context = 5)
    UNION ALL
    SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
         wlpn.inventory_item_id,
         wlpn.organization_id,
          wlpn.revision,
         wlpn.lot_number,
         wlpn.serial_number,
         wlpn.subinventory_code,
         wlpn.locator_id,
         wlpn.parent_lpn_id,
         NVL(wlpn.sealed_status, 2),
         wlpn.gross_weight_uom_code,
         NVL(wlpn.gross_weight, 0),
         content_volume_uom_code,
         NVL(wlpn.content_volume, 0),
         wlpn.lpn_context                 --Added for bug#4202068.
  FROM   wms_license_plate_numbers wlpn,
           mtl_item_locations mil
    WHERE wlpn.organization_id = p_org_id
    AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
   AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                               NVL(wlpn.parent_lpn_id, 0))
    AND wlpn.license_plate_number LIKE (p_lpn)
    AND (wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id ) = 'Y')
   AND wlpn.lpn_context = p_context
  AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
   AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
    AND mil.inventory_location_id = wlpn.locator_id
    -- Bug 4452535
    -- If user provide project/task, select LPN with that project/task
    -- If user provide NULL proj/task, only select LPN with NULL project/task
    --AND NVL(mil.SEGMENT19,-1) = NVL(p_project_id, NVL(mil.SEGMENT19,-1))
    --AND NVL(mil.SEGMENT20,-1) = NVL(p_task_id, NVL(mil.SEGMENT20,-1))
    AND ( (p_project_id IS NOT NULL
           AND NVL(mil.SEGMENT19,-1) = p_project_id)
          OR
          (p_project_id IS NULL
           AND (Nvl(p_calling,-1)='SHIP_UNPACK' OR NVL(mil.SEGMENT19,-1) = -1)) -- Bug 7210544
        )
    AND ( (p_task_id IS NOT NULL
           AND NVL(mil.SEGMENT20,-1) = p_task_id)
          OR
          (p_task_id IS NULL
           AND (Nvl(p_calling,-1)='SHIP_UNPACK' OR NVL(mil.SEGMENT20,-1) = -1)) -- Bug 7210544
        )
    AND (( p_mtrl_sts_check = 'Y' --Bug 3980914
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, p_txn_type_id, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
   AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, p_txn_type_id, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'L') = 'Y'
	 )
 OR
   p_mtrl_sts_check = 'N' --Bug 3980914
)
    ORDER BY license_plate_number;
 ELSE
    IF (l_debug = 1) THEN
       mydebug('pack and picked; pregen=false '||' p_mtrl_sts_check '||p_mtrl_sts_check);
    END IF;
    -- Select LPNs with context "11"
    open x_lpn_lov for
  SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
         wlpn.inventory_item_id,
         wlpn.organization_id,
          wlpn.revision,
         wlpn.lot_number,
         wlpn.serial_number,
         wlpn.subinventory_code,
         wlpn.locator_id,
         wlpn.parent_lpn_id,
         NVL(wlpn.sealed_status, 2),
         wlpn.gross_weight_uom_code,
         NVL(wlpn.gross_weight, 0),
         content_volume_uom_code,
         NVL(wlpn.content_volume, 0),
         wlpn.lpn_context                 --Added for bug#4202068.
  FROM   wms_license_plate_numbers wlpn,
           mtl_item_locations mil
    WHERE wlpn.organization_id = p_org_id
    AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
   AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                               NVL(wlpn.parent_lpn_id, 0))
    AND wlpn.license_plate_number LIKE (p_lpn)
    AND (wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id ) = 'Y')
   AND wlpn.lpn_context = p_context
  AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
   AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
    AND mil.inventory_location_id = wlpn.locator_id
    -- Bug 4452535
    -- If user provide project/task, select LPN with that project/task
    -- If user provide NULL proj/task, only select LPN with NULL project/task
    --AND NVL(mil.SEGMENT19,-1) = NVL(p_project_id, NVL(mil.SEGMENT19,-1))
    --AND NVL(mil.SEGMENT20,-1) = NVL(p_task_id, NVL(mil.SEGMENT20,-1))
    AND ( (p_project_id IS NOT NULL
           AND NVL(mil.SEGMENT19,-1) = p_project_id)
          OR
          (p_project_id IS NULL
           AND (Nvl(p_calling,-1)='SHIP_UNPACK' OR NVL(mil.SEGMENT19,-1) = -1)) -- Bug 7210544
        )
    AND ( (p_task_id IS NOT NULL
           AND NVL(mil.SEGMENT20,-1) = p_task_id)
          OR
          (p_task_id IS NULL
           AND (Nvl(p_calling,-1)='SHIP_UNPACK' OR NVL(mil.SEGMENT20,-1) = -1)) -- Bug 7210544
        )
    AND ( (     p_mtrl_sts_check = 'Y'   --Bug 3980914
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, p_txn_type_id, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
   AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, p_txn_type_id, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'L') = 'Y'
   )
  OR p_mtrl_sts_check = 'N'   --Bug 3980914
   )
   ORDER BY license_plate_number;
  END IF;

END GET_PACK_PICKED_LPNS;



/* For the FP Bug 4057223 --> Base bug#4021746
   This procedure is used in following flows.
   1. For Unpacking of a Child LPN from the Parent LPN. Here no
   need of doing the material check. Because while selecting the
   Parent LPN itself, the material status for the sub/loc had been
   done.So no need for the same check while selecting the Child LPN.
   2. For Consolidating the Child LPNs into a Parent LPN.
   We can consolidate one LPN into another if both reside in
   same SKU. So no need of performing the mtrl status check
   for the child LPNs which are to be consolidated.
   and this applicable only for ***Inventory LPNs***
   */

   PROCEDURE GET_PK_UNPK_INV_LPNS_NO_CHECK
            (
             x_lpn_lov           OUT  nocopy t_genref         ,
             p_org_id            IN   NUMBER           ,
             p_sub               IN   VARCHAR2 := NULL ,
             p_loc_id            IN   VARCHAR2 := NULL ,
             p_not_lpn_id        IN   VARCHAR2 := NULL ,
             p_parent_lpn_id     IN   VARCHAR2 := '0'  ,
             p_txn_type_id       IN   NUMBER   := 0    ,
             p_incl_pre_gen_lpn  IN   VARCHAR2 :='TRUE',
             p_lpn               IN   VARCHAR2,
             p_context           IN   NUMBER := 0,
             p_project_id        IN   nUMBER := NULL,
             p_task_id           IN   NUMBER := NULL,
             p_mtrl_sts_check    IN   VARCHAR2 := 'Y'
             )
     IS
          l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      IF p_incl_pre_gen_lpn = 'TRUE' THEN
	 IF (l_debug = 1) THEN
	    mydebug('pack / unpack and inv lpns with minimal check: pregen=true');
	 END IF;
       --Select LPNs with context "1" or "5"
       open x_lpn_lov for
       SELECT wlpn.license_plate_number,
              wlpn.lpn_id,
              wlpn.inventory_item_id,
              wlpn.organization_id,
              wlpn.revision,
              wlpn.lot_number,
              wlpn.serial_number,
              wlpn.subinventory_code,
              wlpn.locator_id,
              wlpn.parent_lpn_id,
              NVL(wlpn.sealed_status, 2),
              wlpn.gross_weight_uom_code,
              NVL(wlpn.gross_weight, 0),
              wlpn.content_volume_uom_code,
	 NVL(wlpn.content_volume, 0),
	  wlpn.lpn_context
       FROM wms_license_plate_numbers wlpn
       WHERE wlpn.organization_id = p_org_id
       AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
       AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id), NVL(wlpn.parent_lpn_id, 0))
       AND wlpn.license_plate_number LIKE (p_lpn || '%')
       AND (wlpn.lpn_context = 5)
       UNION ALL
       SELECT wlpn.license_plate_number,
              wlpn.lpn_id,
              wlpn.inventory_item_id,
              wlpn.organization_id,
              wlpn.revision,
              wlpn.lot_number,
              wlpn.serial_number,
              wlpn.subinventory_code,
              wlpn.locator_id,
              wlpn.parent_lpn_id,
              NVL(wlpn.sealed_status, 2),
              wlpn.gross_weight_uom_code,
              NVL(wlpn.gross_weight, 0),
              wlpn.content_volume_uom_code,
	 NVL(wlpn.content_volume, 0),
	  wlpn.lpn_context
       FROM wms_license_plate_numbers wlpn
       WHERE wlpn.organization_id = p_org_id
       AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
       AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id), NVL(wlpn.parent_lpn_id, 0))
       AND wlpn.license_plate_number LIKE (p_lpn || '%')
       AND wlpn.lpn_context = 1
       AND wlpn.subinventory_code =  p_sub
       AND wlpn.locator_id = p_loc_id
       AND wlpn.lpn_id NOT IN (SELECT Nvl(lpn_id , -999)
                                 FROM wms_license_plate_numbers wlpn1
                                WHERE wlpn1.organization_id = wlpn.organization_id
                                START WITH wlpn1.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
                                CONNECT BY wlpn1.lpn_id = PRIOR wlpn1.parent_lpn_id )	--13535759
       ORDER BY license_plate_number;
       ELSE

	 IF (l_debug = 1) THEN
	    mydebug('pack / unpack and inv lpns with minimal check ; pregen=false');
	 END IF;

	    -- Select LPNs with context "1"
       open x_lpn_lov for
       SELECT wlpn.license_plate_number,
              wlpn.lpn_id,
              wlpn.inventory_item_id,
              wlpn.organization_id,
              wlpn.revision,
              wlpn.lot_number,
              wlpn.serial_number,
              wlpn.subinventory_code,
              wlpn.locator_id,
              wlpn.parent_lpn_id,
              NVL(wlpn.sealed_status, 2),
              wlpn.gross_weight_uom_code,
              NVL(wlpn.gross_weight, 0),
              wlpn.content_volume_uom_code,
	 NVL(wlpn.content_volume, 0) ,
	  wlpn.lpn_context
       FROM   wms_license_plate_numbers wlpn
       WHERE wlpn.organization_id = p_org_id
       AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
       AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id), NVL(wlpn.parent_lpn_id, 0))
       AND wlpn.license_plate_number LIKE (p_lpn || '%')
       AND wlpn.lpn_context = 1
       AND wlpn.subinventory_code = p_sub
       AND wlpn.locator_id = p_loc_id
       AND wlpn.lpn_id NOT IN (SELECT Nvl(lpn_id , -999)
                                 FROM wms_license_plate_numbers wlpn1
                                WHERE wlpn1.organization_id = wlpn.organization_id
                                START WITH wlpn1.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
                                CONNECT BY wlpn1.lpn_id = PRIOR wlpn1.parent_lpn_id )	--13535759
      ORDER BY license_plate_number;
     END IF;

   END GET_PK_UNPK_INV_LPNS_NO_CHECK ;



--Procedure to fetch LPNs when when transaction type is Split
--and the LPN Context passed is 0 (fetch LPNs with context 1 and 5)
PROCEDURE GET_SPLIT_INV_LPNS(x_lpn_lov        OUT  NOCOPY t_genref         ,
   p_org_id            IN   NUMBER           ,
   p_sub               IN   VARCHAR2 := NULL ,
   p_loc_id            IN   VARCHAR2 := NULL ,
   p_not_lpn_id        IN   VARCHAR2 := NULL ,
   p_parent_lpn_id     IN   VARCHAR2 := '0'  ,
   p_txn_type_id       IN   NUMBER   := 0    ,
   p_incl_pre_gen_lpn  IN   VARCHAR2 :='TRUE',
   p_lpn               IN   VARCHAR2,
   p_context       IN   NUMBER := 0,
          p_project_id        IN   NUMBER := NULL,
          p_task_id           IN   NUMBER := NULL,
	  p_mtrl_sts_check    IN   VARCHAR2 := 'Y' --Bug 3980914
     )
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_incl_pre_gen_lpn = 'TRUE' THEN
    IF (l_debug = 1) THEN
       mydebug('split and inv; pregen=true');
    END IF;
    --Select LPNs with context "1" or "5"
   open x_lpn_lov for
    SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
         wlpn.inventory_item_id,
         wlpn.organization_id,
         revision,
         wlpn.lot_number,
         wlpn.serial_number,
         wlpn.subinventory_code,
         wlpn.locator_id,
         wlpn.parent_lpn_id,
         NVL(wlpn.sealed_status, 2),
         wlpn.gross_weight_uom_code,
         NVL(wlpn.gross_weight, 0),
         wlpn.content_volume_uom_code,
         NVL(wlpn.content_volume, 0),
         wlpn.lpn_context                 --Added for bug#4202068.
  FROM   wms_license_plate_numbers wlpn
    WHERE wlpn.organization_id = p_org_id
    AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
    AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                  NVL(wlpn.parent_lpn_id, 0))
    AND wlpn.license_plate_number LIKE (p_lpn)
    /* Bug 3980914 -For LPN's with context 5, the following condition is not required
    AND wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id ) = 'Y' */
  AND (wlpn.lpn_context = 5)
    UNION ALL
    SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
          NVL(wlpn.inventory_item_id, 0),
          NVL(wlpn.organization_id, 0),
          wlpn.revision,
          wlpn.lot_number,
          wlpn.serial_number,
          wlpn.subinventory_code,
          NVL(wlpn.locator_id, 0),
          NVL(wlpn.parent_lpn_id, 0),
          NVL(wlpn.sealed_status, 2),
          wlpn.gross_weight_uom_code,
          NVL(wlpn.gross_weight, 0),
          wlpn.content_volume_uom_code,
          NVL(wlpn.content_volume, 0),
          wlpn.lpn_context                 --Added for bug#4202068.
  FROM   wms_license_plate_numbers wlpn
    WHERE wlpn.organization_id = p_org_id
   AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
  AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                      NVL(wlpn.parent_lpn_id, 0))
  AND wlpn.license_plate_number LIKE (p_lpn)
    AND (wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id) ='Y')
  AND wlpn.lpn_context = 1
  AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(subinventory_code, '@'))
  AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
   AND (( p_mtrl_sts_check = 'Y' --Bug 3980914
    AND inv_material_status_grp.is_status_applicable
                  ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_PACK, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
  AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_PACK, NULL,
         NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'L') = 'Y'
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
        NULL, NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
  AND inv_material_status_grp.is_status_applicable
               ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
         NULL, NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'L') = 'Y'
         )
    OR p_mtrl_sts_check = 'N' --Bug 3980914
   )
    ORDER BY license_plate_number;
  ELSE
    IF (l_debug = 1) THEN
       mydebug('split and inv; pregen=false');
    END IF;
    --Select LPNs with context "1"
      OPEN x_lpn_lov FOR
      SELECT DISTINCT wlpn.license_plate_number, -- Bug 14345460
             wlpn.lpn_id,
             NVL(wlpn.inventory_item_id, 0),
             NVL(wlpn.organization_id, 0),
             wlpn.revision,
             wlpn.lot_number,
             wlpn.serial_number,
             wlpn.subinventory_code,
             NVL(wlpn.locator_id, 0),
             NVL(wlpn.parent_lpn_id, 0),
             NVL(wlpn.sealed_status, 2),
             wlpn.gross_weight_uom_code,
             NVL(wlpn.gross_weight, 0),
             wlpn.content_volume_uom_code,
             NVL(wlpn.content_volume, 0),
             wlpn.lpn_context
      FROM wms_license_plate_numbers wlpn,
        wms_lpn_contents wlc -- Bug 14345460
      WHERE wlpn.organization_id     = p_org_id
      AND NOT wlpn.lpn_id            = NVL(TO_NUMBER(p_not_lpn_id), -999)
      AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id), NVL(wlpn.parent_lpn_id, 0))
      AND wlpn.license_plate_number LIKE (p_lpn)
      AND wlpn.lpn_id                = wlc.parent_lpn_id -- Bug 14345460
      AND wms_lpn_lovs.sub_lpn_controlled(wlpn.subinventory_code, p_org_id) = 'Y'
      AND wlpn.lpn_context                 = 1
      AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(subinventory_code, '@'))
      AND NVL(wlpn.locator_id, '0')        = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
      AND (( p_mtrl_sts_check = 'Y' AND inv_material_status_grp.is_status_applicable('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_SPLIT,
             NULL, NULL, p_org_id, wlc.inventory_item_id, wlpn.subinventory_code, wlpn.locator_id, wlc.lot_number, NULL, 'A', wlpn.lpn_id) = 'Y' -- Bug 14345460
           )
           OR p_mtrl_sts_check = 'N' --Bug 3980914
          )
      ORDER BY license_plate_number;

  END IF;
END GET_SPLIT_INV_LPNS;

--Procedure to fetch LPNs when when transaction type is Split
--and the LPN Context passed is 0 (fetch LPNs with context 11 and 5)
PROCEDURE GET_SPLIT_PICKED_LPNS(x_lpn_lov        OUT  NOCOPY t_genref         ,
   p_org_id            IN   NUMBER           ,
   p_sub               IN   VARCHAR2 := NULL ,
   p_loc_id            IN   VARCHAR2 := NULL ,
   p_not_lpn_id        IN   VARCHAR2 := NULL ,
   p_parent_lpn_id     IN   VARCHAR2 := '0'  ,
   p_txn_type_id       IN   NUMBER   := 0    ,
   p_incl_pre_gen_lpn  IN   VARCHAR2 :='TRUE',
   p_lpn               IN   VARCHAR2,
   p_context       IN   NUMBER := 0,
          p_project_id        IN   NUMBER := NULL,
          p_task_id           IN   NUMBER := NULL,
   p_mtrl_sts_check    IN   VARCHAR2 := 'Y'  --Bug 3980914
     )
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF p_incl_pre_gen_lpn = 'TRUE' THEN
    IF (l_debug = 1) THEN
       mydebug('split and picked; pregen=true');
    END IF;
    --Select LPNs with context "11" or "5"
   open x_lpn_lov for
    SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
         wlpn.inventory_item_id,
         wlpn.organization_id,
         revision,
         wlpn.lot_number,
         wlpn.serial_number,
         wlpn.subinventory_code,
         wlpn.locator_id,
         wlpn.parent_lpn_id,
         NVL(wlpn.sealed_status, 2),
         wlpn.gross_weight_uom_code,
         NVL(wlpn.gross_weight, 0),
         wlpn.content_volume_uom_code,
         NVL(wlpn.content_volume, 0),
         wlpn.lpn_context                 --Added for bug#4202068.
  FROM   wms_license_plate_numbers wlpn
    WHERE wlpn.organization_id = p_org_id
    AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
    AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                  NVL(wlpn.parent_lpn_id, 0))
    AND wlpn.license_plate_number LIKE (p_lpn)
   /* Bug 3980914 -For LPN's with context 5, the following condition is not required
    AND wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id ) = 'Y' */
  AND (wlpn.lpn_context = 5)
    UNION ALL
    SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
          NVL(wlpn.inventory_item_id, 0),
          NVL(wlpn.organization_id, 0),
          wlpn.revision,
          wlpn.lot_number,
          wlpn.serial_number,
          wlpn.subinventory_code,
          NVL(wlpn.locator_id, 0),
          NVL(wlpn.parent_lpn_id, 0),
          NVL(wlpn.sealed_status, 2),
          wlpn.gross_weight_uom_code,
          NVL(wlpn.gross_weight, 0),
          wlpn.content_volume_uom_code,
          NVL(wlpn.content_volume, 0),
          wlpn.lpn_context                 --Added for bug#4202068.
  FROM   wms_license_plate_numbers wlpn,
           mtl_item_locations mil
    WHERE wlpn.organization_id = p_org_id
   AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
  AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                      NVL(wlpn.parent_lpn_id, 0))
  AND wlpn.license_plate_number LIKE (p_lpn)
    AND (wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id) ='Y')
  AND wlpn.lpn_context = p_context
  AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
  AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
    AND mil.inventory_location_id = wlpn.locator_id
    AND NVL(mil.SEGMENT19, -1) = NVL(p_project_id, NVL(mil.SEGMENT19, -1))
    AND NVL(mil.SEGMENT20, -1) = NVL(p_task_id, NVL(mil.SEGMENT20, -1))
    AND ( (     p_mtrl_sts_check = 'Y' --Bug 3980914
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_PACK, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
  AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_PACK, NULL,
         NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'L') = 'Y'
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
        NULL, NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
  AND inv_material_status_grp.is_status_applicable
               ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
         NULL, NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'L') = 'Y'
	  )
          OR p_mtrl_sts_check = 'N' --Bug 3980914
          )
   ORDER BY license_plate_number;
  ELSE
    IF (l_debug = 1) THEN
       mydebug('split and picked; pregen=false');
    END IF;
    --Select LPNs with context "11"
   open x_lpn_lov for
  SELECT wlpn.license_plate_number,
          wlpn.lpn_id,
          NVL(wlpn.inventory_item_id, 0),
          NVL(wlpn.organization_id, 0),
          wlpn.revision,
          wlpn.lot_number,
          wlpn.serial_number,
          wlpn.subinventory_code,
          NVL(wlpn.locator_id, 0),
          NVL(wlpn.parent_lpn_id, 0),
          NVL(wlpn.sealed_status, 2),
          wlpn.gross_weight_uom_code,
          NVL(wlpn.gross_weight, 0),
          wlpn.content_volume_uom_code,
          NVL(wlpn.content_volume, 0),
          wlpn.lpn_context                 --Added for bug#4202068.
  FROM   wms_license_plate_numbers wlpn,
           mtl_item_locations mil
    WHERE wlpn.organization_id = p_org_id
   AND NOT wlpn.lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
  AND NVL(wlpn.parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id),
                      NVL(wlpn.parent_lpn_id, 0))
  AND wlpn.license_plate_number LIKE (p_lpn)
    AND (wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_org_id) ='Y')
  AND wlpn.lpn_context = p_context
  AND NVL(wlpn.subinventory_code, '@') = NVL(p_sub, NVL(wlpn.subinventory_code, '@'))
  AND NVL(wlpn.locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(wlpn.locator_id, '0'))
    AND mil.inventory_location_id = wlpn.locator_id
    AND NVL(mil.SEGMENT19, -1) = NVL(p_project_id, NVL(mil.SEGMENT19, -1))
    ANd NVL(mil.SEGMENT20, -1) = NVL(p_task_id, NVL(mil.SEGMENT20, -1))
     AND ( (     p_mtrl_sts_check = 'Y' --Bug 3980914
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_PACK, NULL,
        NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
  AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_PACK, NULL,
         NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'L') = 'Y'
    AND inv_material_status_grp.is_status_applicable
              ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
        NULL, NULL, p_org_id, NULL, wlpn.subinventory_code,
        wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
  AND inv_material_status_grp.is_status_applicable
               ('TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_UNPACK,
         NULL, NULL, p_org_id, NULL, wlpn.subinventory_code,
         wlpn.locator_id, NULL, NULL, 'L') = 'Y'
     )
   OR p_mtrl_sts_check = 'N' --Bug 3980914
   )
    ORDER BY license_plate_number;
  END IF;

END GET_SPLIT_PICKED_LPNS;

PROCEDURE GET_PKUPK_LPN_LOV(x_lpn_lov        OUT  NOCOPY t_genref         ,
    p_org_id            IN   NUMBER           ,
    p_sub               IN   VARCHAR2 := NULL ,
    p_loc_id            IN   VARCHAR2 := NULL ,
    p_not_lpn_id        IN   VARCHAR2 := NULL ,
    p_parent_lpn_id     IN   VARCHAR2 := '0'  ,
    p_txn_type_id       IN   NUMBER   := 0    ,
    p_incl_pre_gen_lpn  IN   VARCHAR2 :='TRUE',
    p_lpn               IN   VARCHAR2,
    p_context       IN   NUMBER := 0,
    p_project_id        IN   NUMBER := NULL,
    p_task_id           IN   NUMBER := NULL,
    p_mtrl_sts_check    IN   VARCHAR2 := 'Y',  -- Bug 3980914
    p_calling           IN   VARCHAR2 := NULL  -- Bug 7210544
     )
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  IF (l_debug = 1) THEN
     mydebug('org:'||p_org_id || ' sub:' || p_sub || ' loc:'||p_loc_id ||' parent_lpn:' || p_parent_lpn_id || ' not_lpn:' || p_not_lpn_id );
     mydebug('txn:'||p_txn_type_id ||' incfl:'|| p_incl_pre_gen_lpn || ' con:'||p_context || ' mtrl_chk:'|| p_mtrl_sts_check||' lpn:'|| p_lpn||' Calling '||p_calling);


  END IF;


  If p_txn_type_id IN (INV_GLOBALS.G_TYPE_CONTAINER_PACK,
                       INV_GLOBALS.G_TYPE_CONTAINER_UNPACK) THEN
     IF p_context = 11 THEN
	 mydebug('calling GET_PACK_PICKED_LPNS');
      GET_PACK_PICKED_LPNS(
          x_lpn_lov          => x_lpn_lov,
          p_org_id           => p_org_id,
          p_sub              => p_sub,
          p_loc_id           => p_loc_id,
          p_not_lpn_id       => p_not_lpn_id,
          p_parent_lpn_id    => p_parent_lpn_id,
          p_txn_type_id      => p_txn_type_id,
          p_incl_pre_gen_lpn => p_incl_pre_gen_lpn,
          p_lpn              => p_lpn,
          p_context          => p_context,
          p_project_id       => p_project_id,
          p_task_id          => p_task_id,
	  p_mtrl_sts_check   => p_mtrl_sts_check,  --Bug 3980914
          p_calling          => p_calling);  --Bug 7210544
      --Added for the For bug 4057223 --> Base Bug #4021746
     ELSIF p_sub IS NOT NULL
         AND p_loc_id IS NOT NULL
	   AND p_mtrl_sts_check = 'N' THEN

	IF (l_debug = 1) THEN
	   mydebug('calling GET_PK_UNPK_INV_LPNS_NO_CHECK');
	END IF;

       GET_PK_UNPK_INV_LPNS_NO_CHECK
	 (
	   x_lpn_lov          => x_lpn_lov,
	   p_org_id           => p_org_id,
	   p_sub              => p_sub,
	   p_loc_id           => p_loc_id,
	   p_not_lpn_id       => p_not_lpn_id,
	   p_parent_lpn_id    => p_parent_lpn_id,
	   p_txn_type_id      => p_txn_type_id,
	   p_incl_pre_gen_lpn => p_incl_pre_gen_lpn,
	   p_lpn              => p_lpn,
	   p_context          => p_context,
	   p_project_id       => p_project_id,
	   p_task_id          => p_task_id,
	   p_mtrl_sts_check   => p_mtrl_sts_check);
       --Added for the For bug 4057223 --> Base Bug #4021746
      ELSE

	IF (l_debug = 1) THEN
	   mydebug('calling GET_PACK_INV_LPNS');
	END IF;

      GET_PACK_INV_LPNS(
          x_lpn_lov          => x_lpn_lov,
          p_org_id           => p_org_id,
          p_sub              => p_sub,
          p_loc_id           => p_loc_id,
          p_not_lpn_id       => p_not_lpn_id,
          p_parent_lpn_id    => p_parent_lpn_id,
          p_txn_type_id      => p_txn_type_id,
          p_incl_pre_gen_lpn => p_incl_pre_gen_lpn,
          p_lpn              => p_lpn,
          p_context          => p_context,
          p_project_id       => p_project_id,
          p_task_id          => p_task_id,
	  p_mtrl_sts_check   => p_mtrl_sts_check); --Bug 3980914

    END IF;
  ELSIF p_txn_type_id = INV_GLOBALS.G_TYPE_CONTAINER_SPLIT THEN
    IF p_context = 11 THEN
      GET_SPLIT_PICKED_LPNS(
          x_lpn_lov          => x_lpn_lov,
          p_org_id           => p_org_id,
          p_sub              => p_sub,
          p_loc_id           => p_loc_id,
          p_not_lpn_id       => p_not_lpn_id,
          p_parent_lpn_id    => p_parent_lpn_id,
          p_txn_type_id      => p_txn_type_id,
          p_incl_pre_gen_lpn => p_incl_pre_gen_lpn,
          p_lpn              => p_lpn,
          p_context          => p_context,
          p_project_id       => p_project_id,
          p_task_id          => p_task_id,
	  p_mtrl_sts_check   => p_mtrl_sts_check); --Bug 3980914
    ELSE
      GET_SPLIT_INV_LPNS(
          x_lpn_lov          => x_lpn_lov,
          p_org_id           => p_org_id,
          p_sub              => p_sub,
          p_loc_id           => p_loc_id,
          p_not_lpn_id       => p_not_lpn_id,
          p_parent_lpn_id    => p_parent_lpn_id,
          p_txn_type_id      => p_txn_type_id,
          p_incl_pre_gen_lpn => p_incl_pre_gen_lpn,
          p_lpn              => p_lpn,
          p_context          => p_context,
          p_project_id       => p_project_id,
          p_task_id          => p_task_id,
	  p_mtrl_sts_check   => p_mtrl_sts_check); --Bug 3980914

    END IF;
  ELSE
    --will paste the other sql
     IF (l_debug = 1) THEN
	mydebug('calling other sql');
     END IF;

     open x_lpn_lov for
 select license_plate_number,
        lpn_id,
        NVL(inventory_item_id, 0),
        NVL(organization_id, 0),
        revision,
        lot_number,
        serial_number,
        subinventory_code,
        NVL(locator_id, 0),
        NVL(parent_lpn_id, 0),
        NVL(sealed_status, 2),
        gross_weight_uom_code,
        NVL(gross_weight, 0),
        content_volume_uom_code,
        NVL(content_volume, 0),
        wlpn.lpn_context                 --Added for bug#4202068.
 FROM wms_license_plate_numbers wlpn
       WHERE
 wlpn.organization_id = p_org_id
 AND (wlpn.lpn_context = p_context
  OR (p_context = 0
   AND (wlpn.lpn_context = 1 OR wlpn.lpn_context = 5)))
 AND license_plate_number LIKE (p_lpn)
 ORDER BY license_plate_number;

  END IF;
END GET_PKUPK_LPN_LOV;

PROCEDURE GET_PUP_LPN_LOV(x_lpn_lov        OUT  NOCOPY t_genref         ,
     p_org_id         IN   NUMBER           ,
     p_sub            IN   VARCHAR2 := NULL ,
     p_loc_id         IN   VARCHAR2 := NULL ,
     p_not_lpn_id     IN   VARCHAR2 := NULL ,
     p_parent_lpn_id  IN   VARCHAR2 := '0'  ,
     p_lpn            IN   VARCHAR2
     )
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    open x_lpn_lov for
 select license_plate_number,
        lpn_id,
        NVL(inventory_item_id, 0),
        NVL(organization_id, 0),
        revision,
        lot_number,
        serial_number,
        subinventory_code,
        NVL(locator_id, 0),
        NVL(parent_lpn_id, 0),
        NVL(sealed_status, 2),
        gross_weight_uom_code,
        NVL(gross_weight, 0),
        content_volume_uom_code,
        NVL(content_volume, 0)
 FROM wms_license_plate_numbers wlpn
 WHERE wlpn.organization_id = p_org_id
 AND NVL(subinventory_code, '@') = NVL(p_sub, NVL(subinventory_code, '@'))
 AND NVL(locator_id, '0') = NVL(TO_NUMBER(p_loc_id), NVL(locator_id, '0'))
  AND NOT lpn_id = NVL(TO_NUMBER(p_not_lpn_id), -999)
 AND NVL(parent_lpn_id, 0) = NVL(TO_NUMBER(p_parent_lpn_id), NVL(parent_lpn_id, 0))
      AND license_plate_number LIKE (p_lpn)
      ORDER BY license_plate_number;

END GET_PUP_LPN_LOV;

PROCEDURE CHILD_LPN_EXISTS(p_lpn_id  IN   NUMBER ,
      x_out     OUT  NOCOPY NUMBER
      )
IS
l_temp_num      NUMBER;
CURSOR child_lpn_cursor IS
   SELECT lpn_id
     FROM wms_license_plate_numbers
     WHERE parent_lpn_id = p_lpn_id;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   OPEN child_lpn_cursor;
   FETCH child_lpn_cursor INTO l_temp_num;
   IF child_lpn_cursor%notfound THEN
      x_out := 2;
    ELSE
      x_out := 1;
   END IF;
   CLOSE child_lpn_cursor;

END CHILD_LPN_EXISTS;


PROCEDURE VALIDATE_PHYINV_LPN
  (p_lpn                    IN   VARCHAR2  ,
   p_dynamic_entry_flag     IN   NUMBER    ,
   p_physical_inventory_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   x_result                 OUT  NOCOPY NUMBER)
IS
l_count             NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (p_dynamic_entry_flag = 1) THEN -- Dynamic entries are allowed
      -- Select all LPN's which exist in the given org, sub, loc
      SELECT COUNT(*)
 INTO l_count
 FROM wms_license_plate_numbers
 WHERE organization_id = p_organization_id
 AND subinventory_code = p_subinventory_code
 AND Nvl(locator_id, -99999) = Nvl(p_locator_id, -99999)
 AND license_plate_number = p_lpn;

      IF (l_count = 1) THEN
  -- Validation is successful
  x_result := 1;
       ELSE
  -- Validation is not successful
  x_result := 2;
      END IF;

    ELSE -- Dynamic entries are not allowed
      -- Select only LPN's that exist in table MTL_PHYSICAL_INVENTORY_TAGS
      SELECT COUNT(*)
 INTO l_count
 FROM wms_license_plate_numbers wlpn,
 mtl_physical_inventory_tags mpit
 WHERE wlpn.organization_id = p_organization_id
 AND wlpn.subinventory_code = p_subinventory_code
 AND Nvl(wlpn.locator_id, -99999) = Nvl(p_locator_id, -99999)
 AND wlpn.license_plate_number LIKE (p_lpn)
 AND wlpn.lpn_id = mpit.parent_lpn_id
 AND mpit.organization_id = p_organization_id
 AND mpit.physical_inventory_id = p_physical_inventory_id;

      IF (l_count = 1) THEN
  -- Validation is successful
  x_result := 1;
       ELSE
  -- Validation is not successful
  x_result := 2;
      END IF;

   END IF;

END VALIDATE_PHYINV_LPN;


PROCEDURE VALIDATE_CYCLECOUNT_LPN
  (p_lpn                    IN   VARCHAR2  ,
   p_unscheduled_entry      IN   NUMBER    ,
   p_cycle_count_header_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   x_result                 OUT  NOCOPY NUMBER)
IS
l_count             NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF (p_unscheduled_entry = 1) THEN -- Unscheduled entries are allowed
      -- Select all LPN's which exist in the given org, sub, loc
      SELECT COUNT(*)
 INTO l_count
 FROM wms_license_plate_numbers
 WHERE organization_id = p_organization_id
 AND subinventory_code = p_subinventory_code
 AND NVL(locator_id, -99999) = NVL(p_locator_id, -99999)
 AND license_plate_number = p_lpn;

      IF (l_count = 1) THEN
  -- Validation is successful
  x_result := 1;
       ELSE
  -- Validation is not successful
  x_result := 2;
      END IF;

    ELSE -- Unscheduled entries are not allowed
      -- Select only LPN's that exist in table MTL_CYCLE_COUNT_ENTRIES
      SELECT COUNT(*)
 INTO l_count
 FROM wms_license_plate_numbers wlpn,
 mtl_cycle_count_entries mcce
 WHERE wlpn.organization_id = p_organization_id
 AND wlpn.subinventory_code = p_subinventory_code
 AND NVL(wlpn.locator_id, -99999) = NVL(p_locator_id, -99999)
 AND wlpn.license_plate_number LIKE (p_lpn)
 AND wlpn.lpn_id = mcce.parent_lpn_id
 AND mcce.organization_id = p_organization_id
 AND mcce.cycle_count_header_id = p_cycle_count_header_id;

      IF (l_count = 1) THEN
  -- Validation is successful
  x_result := 1;
       ELSE
  -- Validation is not successful
  x_result := 2;
      END IF;

   END IF;

END VALIDATE_CYCLECOUNT_LPN;



PROCEDURE VALIDATE_LPN_AGAINST_ORG
  (p_lpn                    IN   VARCHAR2  ,
   p_organization_id        IN   NUMBER    ,
   x_result                 OUT  NOCOPY NUMBER)
IS
l_lpn               WMS_container_pub.LPN;
l_result            NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_lpn.lpn_id := NULL;
   l_lpn.license_plate_number := p_lpn;
   l_result := wms_container_pub.Validate_LPN(l_lpn);
   IF (l_result = INV_Validate.F) THEN
      -- LPN was not found
      x_result := 2;
    ELSE
      -- LPN was found and is therefore valid
      x_result := 1;
   END IF;

END VALIDATE_LPN_AGAINST_ORG;



PROCEDURE GET_LPN_VALUES
  (p_lpn                      IN   VARCHAR2  ,
   p_organization_id          IN   NUMBER    ,
   x_license_plate_number     OUT  NOCOPY VARCHAR2  ,
   x_lpn_id                   OUT  NOCOPY NUMBER    ,
   x_inventory_item_id        OUT  NOCOPY NUMBER    ,
   x_organization_id          OUT  NOCOPY NUMBER    ,
   x_revision                 OUT  NOCOPY VARCHAR2  ,
   x_lot_number               OUT  NOCOPY VARCHAR2  ,
   x_serial_number            OUT  NOCOPY VARCHAR2  ,
   x_subinventory_code        OUT  NOCOPY VARCHAR2  ,
   x_locator_id               OUT  NOCOPY NUMBER    ,
   x_parent_lpn_id            OUT  NOCOPY NUMBER    ,
   x_sealed_status            OUT  NOCOPY NUMBER    ,
   x_gross_weight_uom_code    OUT  NOCOPY VARCHAR2  ,
   x_gross_weight             OUT  NOCOPY NUMBER    ,
   x_content_volume_uom_code  OUT  NOCOPY VARCHAR2  ,
   x_content_volume           OUT  NOCOPY NUMBER)
IS
l_lpn_record             LPN_RECORD;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   SELECT license_plate_number,
            lpn_id,
            NVL(inventory_item_id, 0),
            NVL(organization_id, 0),
            revision,
            lot_number,
            serial_number,
            subinventory_code,
            NVL(locator_id, 0),
            NVL(parent_lpn_id, 0),
            NVL(sealed_status, 2),
            gross_weight_uom_code,
            NVL(gross_weight, 0),
            content_volume_uom_code,
            NVL(content_volume, 0)
     INTO l_lpn_record
     FROM wms_license_plate_numbers
     WHERE license_plate_number = p_lpn
     AND organization_id = p_organization_id
     ORDER BY license_plate_number;

   x_license_plate_number     := l_lpn_record.license_plate_number;
   x_lpn_id                   := l_lpn_record.lpn_id;
   x_inventory_item_id        := l_lpn_record.inventory_item_id;
   x_organization_id          := l_lpn_record.organization_id;
   x_revision                 := l_lpn_record.revision;
   x_lot_number               := l_lpn_record.lot_number;
   x_serial_number            := l_lpn_record.serial_number;
   x_subinventory_code        := l_lpn_record.subinventory_code;
   x_locator_id               := l_lpn_record.locator_id;
   x_parent_lpn_id            := l_lpn_record.parent_lpn_id;
   x_sealed_status            := l_lpn_record.sealed_status;
   x_gross_weight_uom_code    := l_lpn_record.gross_weight_uom_code;
   x_gross_weight             := l_lpn_record.gross_weight;
   x_content_volume_uom_code  := l_lpn_record.content_volume_uom_code;
   x_content_volume           := l_lpn_record.content_volume;

END GET_LPN_VALUES;








--      Name: GET_INSPECT_LPN_LOV
--
--      Input parameters:
--       p_lpn   which restricts LOV SQL to the user input text
--
--      Output parameters:
--       x_lpn_lov      returns LOV rows as reference cursor
--
--      Functions: This API returns valid LPN and lpn_id whose contents have to be inspected
--     in Mobile Inspection form
--

PROCEDURE GET_INSPECT_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_lpn      IN   VARCHAR2,
   p_organization_id          IN   NUMBER
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- inspection_status in mtl_txn_request_lines could have values {null,1,2,3}
   -- mapping to {Inspection not needed, Inspection needed, Accepted,  Rejected }
   -- bug 8405606 changed the condition so as to be able to inspect an accepted lpn and rejected lpn also


   OPEN x_lpn_lov FOR
     SELECT distinct
            a.license_plate_number,
            a.lpn_id,
            NVL(a.inventory_item_id, 0),
            NVL(a.organization_id, 0),
            a.revision,
            a.lot_number,
            a.serial_number,
            a.subinventory_code,
            NVL(a.locator_id, 0),
            NVL(a.parent_lpn_id, 0),
            NVL(a.sealed_status, 2),
            a.gross_weight_uom_code,
            NVL(a.gross_weight, 0),
            a.content_volume_uom_code,
            NVL(a.content_volume, 0),
            nvl(rec_count.lpn_content_count, 0)
     FROM wms_license_plate_numbers a,
          mtl_txn_request_lines     b,
          (SELECT count(*) lpn_content_count,grouped_contents.lpn_id
	   FROM (SELECT mtrl.lpn_id lpn_id, -- Need extra grouping to group
		 mtrl.inventory_item_id item_id,
		 mtrl.revision revision
		 --BUG 3358288: Use MOL to calculate the count instead of
		 --using WLC because there may be items there does not
		 --require inspection
		 FROM   wms_license_plate_numbers wlpn, mtl_txn_request_lines mtrl
		 WHERE  wlpn.license_plate_number LIKE (p_lpn)
		 AND    mtrl.lpn_id = wlpn.lpn_id
		  AND   mtrl.inspection_status is not null -- bug 8405606
		 AND    mtrl.wms_process_flag = 1
		 AND    mtrl.line_status = 7
		 AND    (mtrl.quantity-Nvl(mtrl.quantity_delivered,0))>0
		 --GROUP BY mtrl.lpn_id, mtrl.inventory_item_id,Nvl(mtrl.revision,-1)) grouped_contents
	         --Fix for Bug 11858596. Taken out NVL() for mtrl.revision to
                 --make it in line with select statement
		 GROUP BY mtrl.lpn_id, mtrl.inventory_item_id,mtrl.revision) grouped_contents
	    GROUP BY grouped_contents.lpn_id) rec_count
     WHERE a. license_plate_number LIKE (p_lpn)
     and   a.lpn_id = b.lpn_id
     and   a.lpn_context in (3,5)
     and   b.inspection_status is not null -- bug 8405606
     --  Bug 2377796
     --  Check to make sure that the processing for mtl_txn_request_lines is completed or not.
     and   b.wms_process_flag = 1
     AND   b.line_status = 7
     AND   (b.quantity-Nvl(b.quantity_delivered,0))>0
     and   b.organization_id = p_organization_id
     and   a.lpn_id = rec_count.lpn_id --(+) //Bug 3435093
     and   nvl(rec_count.lpn_content_count, 0) > 0;


END GET_INSPECT_LPN_LOV;










--
-- Procedure to retrieve LPNs in Inventory which contain only the specific
-- item having less than equal to specified qty in the specified location.
--  Called from LPNLOV.java
--
PROCEDURE GET_MO_LPN
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_inv_item_id            IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_qty                    IN   NUMBER) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
begin
 OPEN x_lpn_lov FOR
  select lpnc.parent_lpn_id lpn_id,
      lpn.license_plate_number  lpn,
            sum(lpnc.quantity) quantity
  from wms_lpn_contents lpnc, wms_license_plate_numbers lpn
  where lpn.organization_id = p_organization_id
  and lpnc.inventory_item_id = p_inv_item_id
  and lpnc.parent_lpn_id = lpn.lpn_id
  and nvl(lpn.SUBINVENTORY_CODE,'@@@') = nvl(p_subinventory_code,'@@@')
  and nvl(lpn.LOCATOR_ID, 0)  = nvl(p_locator_id, 0)
    and lpn.license_plate_number like (p_lpn)
  and lpn.lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
   and not exists (select null
                    from wms_lpn_contents
                    where  parent_lpn_id = lpnc.parent_lpn_id
                      and inventory_item_id <> lpnc.inventory_item_id)
  group by lpnc.parent_lpn_id, lpn.license_plate_number
  having sum(lpnc.quantity) <= p_qty;

end;


-- Neted LPN changes added p_mode parameter.
-- For express receipts the value of Mode will be 'E'
-- For confirm receipts the value of Mode will be 'C'
-- If the value of p_mode is NULL then that means the customer
-- has Patchset I Java page. In this case we will use the old query.


PROCEDURE
  GET_VENDOR_LPN
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_shipment_header_id     IN   VARCHAR2  ,
   p_mode                   IN   VARCHAR2  ,
   p_inventory_item_id      IN   VARCHAR2
)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN


  -- Nested LPN changes if p_mode is NULL then it is called Before Patchset J,
  -- If p_mode is 'E' called from Express page. If it is 'C' then called from confirm page.

  -- For getting the No of LPNs attached to a Shipment Header, the Like clause
  -- is commented, because it is not necessary to check with pattern matching
  -- in this query. (Base Bug : 3080274).

  IF p_mode IS NULL THEN
    OPEN x_lpn_lov FOR
      SELECT
      lpn.license_plate_number,
      lpn.lpn_id,
      NVL(lpn.inventory_item_id, 0),
      NVL(lpn.organization_id, 0),
      lpn.revision,
      lpn.lot_number,
      lpn.serial_number,
      lpn.subinventory_code,
      NVL(lpn.locator_id, 0),
      NVL(lpn.parent_lpn_id, 0),
      NVL(lpn.sealed_status, 2),
      lpn.gross_weight_uom_code,
      NVL(lpn.gross_weight, 0),
      lpn.content_volume_uom_code,
      NVL(lpn.content_volume, 0),
      lpn.source_header_id,
      rsh.shipment_num,
      count_row.n,
      rsh.shipment_header_id
      FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh,
      (SELECT COUNT(*) n
       FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh
       --WHERE lpn.license_plate_number LIKE (p_lpn)--Bug 3090000
       WHERE lpn.lpn_context IN (6, 7)  -- context for vendor LPN
       AND rsh.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsh.shipment_header_id)
       AND (lpn.source_header_id = rsh.shipment_header_id
            OR lpn.source_name = rsh.shipment_num)
       ) count_row
      WHERE lpn.license_plate_number LIKE (p_lpn)
      AND lpn.lpn_context IN (6, 7)  -- context for vendor LPN
      AND rsh.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsh.shipment_header_id)
      AND (lpn.source_header_id = rsh.shipment_header_id
           OR lpn.source_name = rsh.shipment_num)
      -- Nested LPN changes , For I Patchset donot show nested LPNs
      AND lpn.lpn_id NOT IN (SELECT parent_lpn_id FROM wms_license_plate_numbers WHERE parent_lpn_id = lpn.lpn_id )
      AND lpn.parent_lpn_id IS NULL;
   ELSIF p_mode = 'E' THEN

     -- As Part of per bug 3435093 if shipment_header_id is not null
     -- removed the Nvl condition around shipment_header_id to pick the index.

     IF p_shipment_header_id IS NOT NULL  THEN

	OPEN x_lpn_lov FOR
	  SELECT
	  wlpn1.license_plate_number,
	  wlpn1.lpn_id,
	  NVL(wlpn1.inventory_item_id, 0),
	  NVL(wlpn1.organization_id, 0),
	  wlpn1.revision,
	  wlpn1.lot_number,
	  wlpn1.serial_number,
	  wlpn1.subinventory_code,
	  NVL(wlpn1.locator_id, 0),
	  NVL(wlpn1.parent_lpn_id, 0),
	  NVL(wlpn1.sealed_status, 2),
	  wlpn1.gross_weight_uom_code,
	  NVL(wlpn1.gross_weight, 0),
	  wlpn1.content_volume_uom_code,
	  NVL(wlpn1.content_volume, 0),
	  wlpn1.source_header_id,
	  rsh.shipment_num,
	  1,--This is a dummy value.  Actually cound will be calculated in validate_from_lpn
	  rsh.shipment_header_id
	  FROM  wms_license_plate_numbers wlpn1, rcv_shipment_headers rsh
	  WHERE rsh.shipment_header_id = p_shipment_header_id
	  AND   ((wlpn1.lpn_context = 6 AND wlpn1.organization_id = rsh.organization_id) OR
		 (wlpn1.lpn_context = 7 AND wlpn1.organization_id = rsh.ship_to_org_id))
	  AND   wlpn1.source_name = rsh.shipment_num
	  AND   wlpn1.license_plate_number LIKE (p_lpn)
	  and exists (SELECT wlpn2.lpn_id
  		      FROM   wms_license_plate_numbers wlpn2
  		      START WITH wlpn2.lpn_id = wlpn1.lpn_id
  		      CONNECT BY PRIOR wlpn2.lpn_id = wlpn2.parent_lpn_id
		      INTERSECT
		      SELECT asn_lpn_id
		      FROM rcv_shipment_lines rsl
		      WHERE rsl.shipment_header_id = p_shipment_header_id
		      AND   NOT exists (SELECT 1
					FROM   rcv_transactions_interface rti
					WHERE  rti.lpn_id = rsl.asn_lpn_id
					AND    rti.transfer_lpn_id = rsl.asn_lpn_id
					AND    rti.to_organization_id = rsl.to_organization_id
					AND    rti.processing_status_code <> 'ERROR'
					AND    rti.transaction_status_code <> 'ERROR'
					)
		      );
     ELSE
       OPEN x_lpn_lov FOR
        SELECT
        lpn.license_plate_number,
        lpn.lpn_id,
        NVL(lpn.inventory_item_id, 0),
        NVL(lpn.organization_id, 0),
        lpn.revision,
        lpn.lot_number,
        lpn.serial_number,
        lpn.subinventory_code,
        NVL(lpn.locator_id, 0),
        NVL(lpn.parent_lpn_id, 0),
        NVL(lpn.sealed_status, 2),
        lpn.gross_weight_uom_code,
        NVL(lpn.gross_weight, 0),
        lpn.content_volume_uom_code,
        NVL(lpn.content_volume, 0),
        lpn.source_header_id,
        rsh.shipment_num,
        count_row.n,
        rsh.shipment_header_id
        FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh,
        (SELECT COUNT(*) n
         FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh
         --WHERE lpn.license_plate_number LIKE (p_lpn) --Bug 3090000
         WHERE lpn.lpn_context IN (6, 7)  -- context for vendor LPN
         --AND rsh.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsh.shipment_header_id)
         AND (lpn.source_header_id = rsh.shipment_header_id
             OR lpn.source_name = rsh.shipment_num)
         ) count_row
        WHERE lpn.license_plate_number LIKE (p_lpn)
        AND lpn.lpn_context IN (6, 7)  -- context for vendor LPN
        --AND rsh.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsh.shipment_header_id)
        AND (lpn.source_header_id = rsh.shipment_header_id
             OR lpn.source_name = rsh.shipment_num) ;
     END IF; -- For shipment Header id is null

  -- Nested LPN changes If mode is 'C' then the LOV is for Confirm transactions
  -- In case of Confirm transaction we show LPNs which have immediate contents.
  ELSIF p_mode= 'C' THEN

    -- This is changed based on Item Info, case for Item Initiated Receipt.
    -- If Item info is present or passed from the UI then LPN should be restrcied based on Item
    -- Otherwise all the LPN's for the shipment should be displayed in the LOV

    if p_inventory_item_id is null then
      IF p_shipment_header_id IS NOT NULL THEN
        OPEN x_lpn_lov FOR
         SELECT
         lpn.license_plate_number,
         lpn.lpn_id,
         NVL(lpn.inventory_item_id, 0),
         NVL(lpn.organization_id, 0),
         lpn.revision,
         lpn.lot_number,
         lpn.serial_number,
         lpn.subinventory_code,
         NVL(lpn.locator_id, 0),
         NVL(lpn.parent_lpn_id, 0),
         NVL(lpn.sealed_status, 2),
         lpn.gross_weight_uom_code,
         NVL(lpn.gross_weight, 0),
         lpn.content_volume_uom_code,
         NVL(lpn.content_volume, 0),
         lpn.source_header_id,
         rsh.shipment_num,
         count_row.n,
         rsh.shipment_header_id
         FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh,
         ( SELECT COUNT(*) n
             FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh
            --WHERE lpn.license_plate_number LIKE (p_lpn) --Bug 3090000
              WHERE lpn.lpn_context IN (6, 7)  -- context for vendor LPN
              AND rsh.shipment_header_id = p_shipment_header_id
              AND (lpn.source_header_id = rsh.shipment_header_id
               OR lpn.source_name = rsh.shipment_num)
              AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents WHERE parent_lpn_id = lpn.lpn_id)
          ) count_row
          WHERE lpn.license_plate_number LIKE (p_lpn)
            AND lpn.lpn_context IN (6, 7)  -- context for vendor LPN
            AND rsh.shipment_header_id = p_shipment_header_id
            AND (lpn.source_header_id = rsh.shipment_header_id
             OR lpn.source_name = rsh.shipment_num)
            AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents WHERE parent_lpn_id = lpn.lpn_id);

      ELSE -- for if p_shipment_header_id is not null
        OPEN x_lpn_lov FOR
         SELECT
         lpn.license_plate_number,
         lpn.lpn_id,
         NVL(lpn.inventory_item_id, 0),
         NVL(lpn.organization_id, 0),
         lpn.revision,
         lpn.lot_number,
         lpn.serial_number,
         lpn.subinventory_code,
         NVL(lpn.locator_id, 0),
         NVL(lpn.parent_lpn_id, 0),
         NVL(lpn.sealed_status, 2),
         lpn.gross_weight_uom_code,
         NVL(lpn.gross_weight, 0),
         lpn.content_volume_uom_code,
         NVL(lpn.content_volume, 0),
         lpn.source_header_id,
         rsh.shipment_num,
         count_row.n,
         rsh.shipment_header_id
         FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh,
         ( SELECT COUNT(*) n
             FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh
            --WHERE lpn.license_plate_number LIKE (p_lpn) --Bug 3090000
              WHERE lpn.lpn_context IN (6, 7)  -- context for vendor LPN
              --AND rsh.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsh.shipment_header_id)
              AND (lpn.source_header_id = rsh.shipment_header_id
               OR lpn.source_name = rsh.shipment_num)
              AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents WHERE parent_lpn_id = lpn.lpn_id)
          ) count_row
          WHERE lpn.license_plate_number LIKE (p_lpn)
            AND lpn.lpn_context IN (6, 7)  -- context for vendor LPN
            --AND rsh.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsh.shipment_header_id)
            AND (lpn.source_header_id = rsh.shipment_header_id
             OR lpn.source_name = rsh.shipment_num)
            AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents WHERE parent_lpn_id = lpn.lpn_id);

      END IF; -- end if for if p_shipment_header_id is not null
    ELSE
      IF p_shipment_header_id IS NOT NULL THEN
        OPEN x_lpn_lov FOR
         SELECT
         lpn.license_plate_number,
         lpn.lpn_id,
         NVL(lpn.inventory_item_id, 0),
         NVL(lpn.organization_id, 0),
         lpn.revision,
         lpn.lot_number,
         lpn.serial_number,
         lpn.subinventory_code,
         NVL(lpn.locator_id, 0),
         NVL(lpn.parent_lpn_id, 0),
         NVL(lpn.sealed_status, 2),
         lpn.gross_weight_uom_code,
         NVL(lpn.gross_weight, 0),
         lpn.content_volume_uom_code,
         NVL(lpn.content_volume, 0),
         lpn.source_header_id,
         rsh.shipment_num,
         count_row.n,
         rsh.shipment_header_id
         FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh,
         ( SELECT COUNT(*) n
             FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh
            --WHERE lpn.license_plate_number LIKE (p_lpn) --Bug 3090000
              WHERE lpn.lpn_context IN (6, 7)  -- context for vendor LPN
              AND rsh.shipment_header_id = p_shipment_header_id
              AND (lpn.source_header_id = rsh.shipment_header_id
               OR lpn.source_name = rsh.shipment_num)
              AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents WHERE parent_lpn_id = lpn.lpn_id)
          ) count_row
          WHERE lpn.license_plate_number LIKE (p_lpn)
            AND lpn.lpn_context IN (6, 7)  -- context for vendor LPN
            AND rsh.shipment_header_id = p_shipment_header_id
            AND (lpn.source_header_id = rsh.shipment_header_id
             OR lpn.source_name = rsh.shipment_num)
            AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents WHERE parent_lpn_id = lpn.lpn_id
                                             and inventory_item_id = p_inventory_item_id );

      ELSE -- if p_shipment_header_id is null
        OPEN x_lpn_lov FOR
         SELECT
         lpn.license_plate_number,
         lpn.lpn_id,
         NVL(lpn.inventory_item_id, 0),
         NVL(lpn.organization_id, 0),
         lpn.revision,
         lpn.lot_number,
         lpn.serial_number,
         lpn.subinventory_code,
         NVL(lpn.locator_id, 0),
         NVL(lpn.parent_lpn_id, 0),
         NVL(lpn.sealed_status, 2),
         lpn.gross_weight_uom_code,
         NVL(lpn.gross_weight, 0),
         lpn.content_volume_uom_code,
         NVL(lpn.content_volume, 0),
         lpn.source_header_id,
         rsh.shipment_num,
         count_row.n,
         rsh.shipment_header_id
         FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh,
         ( SELECT COUNT(*) n
             FROM wms_license_plate_numbers lpn, rcv_shipment_headers rsh
            --WHERE lpn.license_plate_number LIKE (p_lpn) --Bug 3090000
              WHERE lpn.lpn_context IN (6, 7)  -- context for vendor LPN
              --AND rsh.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsh.shipment_header_id)
              AND (lpn.source_header_id = rsh.shipment_header_id
               OR lpn.source_name = rsh.shipment_num)
              AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents WHERE parent_lpn_id = lpn.lpn_id)
          ) count_row
          WHERE lpn.license_plate_number LIKE (p_lpn)
            AND lpn.lpn_context IN (6, 7)  -- context for vendor LPN
            --AND rsh.shipment_header_id = Nvl(To_number(p_shipment_header_id), rsh.shipment_header_id)
            AND (lpn.source_header_id = rsh.shipment_header_id
             OR lpn.source_name = rsh.shipment_num)
            AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents WHERE parent_lpn_id = lpn.lpn_id
                                             and inventory_item_id = p_inventory_item_id );
      END IF; -- else part of if p_shipment_header_id is  not null
    END IF; -- else part of if p_inventory_item_id is null
  END IF;


END GET_VENDOR_LPN;

/*  PJM Integration: Added to get the concatenated segments of physical locator,
 *  project id, project number, task id and task number.
 *  Use the table mtl_item_locations instead of mtl_item_locations_kfv.
 */
PROCEDURE GET_ITEM_LPN_LOV
  (x_lpn_lov                       OUT  NOCOPY t_genref,
   p_organization_id               IN   NUMBER,
   p_lot_number                    IN   VARCHAR2,
   p_inventory_item_id             IN   NUMBER,
   p_revision                      IN   VARCHAR2,
   p_lpn                           IN   VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   OPEN     x_lpn_lov
   FOR
     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlc.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlc.revision,
            wlc.lot_number,
            wlc.serial_number,
            wlpn.subinventory_code,
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0),
            --milk.concatenated_segments locator_code,
            INV_PROJECT.GET_LOCSEGS(mil.inventory_location_id, p_organization_id),
            wlc.cost_group_id,
            INV_PROJECT.GET_PROJECT_ID,
            INV_PROJECT.GET_PROJECT_NUMBER,
            INV_PROJECT.GET_TASK_ID,
            INV_PROJECT.GET_TASK_NUMBER
     FROM   wms_license_plate_numbers  wlpn,
            wms_lpn_contents           wlc,
            mtl_item_locations         mil
     WHERE  (mil.inventory_location_id =  wlpn.locator_id
        AND  wlpn.locator_id IS NOT NULL)
     AND    (   (wlc.revision                = p_revision
                 AND  p_revision IS NOT NULL)
             OR (wlc.revision    IS NULL
                 AND p_revision  IS NULL))
     AND    wlc.inventory_item_id          =  p_inventory_item_id
     AND    ( (wlc.lot_number              =  p_lot_number
               AND  p_lot_number IS NOT NULL)                 OR
              (wlc.lot_number    LIKE   '%'
               AND  p_lot_number IS NULL))
     AND    wlpn.license_plate_number     LIKE  (p_lpn)
     AND    wlpn.lpn_id                    = wlc.parent_lpn_id
     AND    wlpn.lpn_context               =  1
     AND    wlpn.parent_lpn_id             IS NULL
     AND    wlpn.organization_id           =  p_organization_id;
END GET_ITEM_LPN_LOV;

-- Procedure for the result lot of Lot split/merge/translate.
-- For the result lot, do not need to check for inventory item id.
/*  PJM Integration: Added to get the concatenated segments of physical locator,
 *  project id, project number, task id and task number.
 *  Use the table mtl_item_locations instead of mtl_item_locations_kfv.
 */
PROCEDURE GET_LOT_LPN_LOV
  (x_lpn_lov                       OUT  NOCOPY t_genref,
   p_organization_id               IN   NUMBER,
   p_lpn                           IN   VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   OPEN x_lpn_lov FOR
     SELECT distinct wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlpn.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            wlpn.subinventory_code,
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0),
            --milk.concatenated_segments locator_code
            INV_PROJECT.GET_LOCSEGS(mil.inventory_location_id, p_organization_id),
            INV_PROJECT.GET_PROJECT_ID,
            INV_PROJECT.GET_PROJECT_NUMBER,
            INV_PROJECT.GET_TASK_ID,
            INV_PROJECT.GET_TASK_NUMBER
     FROM   wms_license_plate_numbers wlpn,
            mtl_item_locations        mil
     WHERE  mil.inventory_location_id(+) = wlpn.locator_id  --OUTER JOIN is added for bug 3876495
     AND    wlpn.license_plate_number LIKE (p_lpn)
     AND    wlpn.organization_id = p_organization_id
     AND    wlpn.lpn_context IN (1,5) --LPN_CONTEXT 5 is Added for bug3876495.
     ORDER BY license_plate_number;
END GET_LOT_LPN_LOV;



PROCEDURE GET_RCV_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2,
   p_from_lpn_id  IN VARCHAR2,
   p_project_id   in number,
   p_task_id   in number
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   IF p_project_id is not null then
     OPEN x_lpn_lov FOR
     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlpn.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            wlpn.subinventory_code,
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
     FROM wms_license_plate_numbers wlpn
     WHERE wlpn.license_plate_number LIKE (p_lpn)
     AND wlpn.organization_id = p_org_id
     and wlpn.lpn_context = 3
     AND exists (
         select lpn_id
    from   mtl_txn_request_lines mtrl
    where  mtrl.organization_id = p_org_id
    and    mtrl.project_id = p_project_id
    and    mtrl.lpn_id = wlpn.lpn_id
    and    nvl(task_id,-9999) = nvl(p_task_id,-9999)
            )
     UNION
     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlpn.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            wlpn.subinventory_code,
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
     FROM  wms_license_plate_numbers wlpn
     WHERE wlpn.license_plate_number LIKE (p_lpn)
     AND   wlpn.organization_id = p_org_id
     and   exists
         ( select inventory_location_id
      from mtl_item_locations mil
      where organization_id = p_org_id
      and   nvl(wlpn.subinventory_code,'@@@') = nvl(mil.subinventory_code,'@@@')
      and   mil.project_id = p_project_id
      and   wlpn.locator_id = mil.inventory_location_id
      and   nvl(task_id,-9999) = nvl(p_task_id,-9999)
     )
     and   wlpn.lpn_context = 1
     AND   inv_material_status_grp.is_status_applicable
       ('TRUE',
        NULL,
        INV_GLOBALS.G_TYPE_CONTAINER_PACK,
        NULL,
        NULL,
        p_org_id,
        NULL,
        wlpn.subinventory_code,
        wlpn.locator_id,
        NULL,
        NULL,
        'Z') = 'Y'
       AND inv_material_status_grp.is_status_applicable
       ('TRUE',
        NULL,
        INV_GLOBALS.G_TYPE_CONTAINER_PACK,
        NULL,
        NULL,
        p_org_id,
        NULL,
        wlpn.subinventory_code,
        wlpn.locator_id,
        NULL,
        NULL,
        'L') = 'Y'
     UNION
     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlpn.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            wlpn.subinventory_code,
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
     FROM  wms_license_plate_numbers wlpn
     WHERE wlpn.license_plate_number LIKE (p_lpn)
     AND   wlpn.organization_id = p_org_id
     and   ( lpn_context = 5 or lpn_id = p_from_lpn_id )
     ORDER BY 1;
   elsif p_project_id is null then
     OPEN x_lpn_lov FOR
     SELECT license_plate_number,
            lpn_id,
            NVL(inventory_item_id, 0),
            NVL(organization_id, 0),
            revision,
            lot_number,
            serial_number,
            subinventory_code,
            NVL(locator_id, 0),
            NVL(parent_lpn_id, 0),
            NVL(sealed_status, 2),
            gross_weight_uom_code,
            NVL(gross_weight, 0),
            content_volume_uom_code,
            NVL(content_volume, 0)
     FROM wms_license_plate_numbers wlpn
     WHERE license_plate_number LIKE (p_lpn)
     AND organization_id = p_org_id
     AND lpn_context = 3
     and exists (
         select mtrl.lpn_id
    from   mtl_txn_request_lines mtrl
    where  mtrl.organization_id = p_org_id
    and    mtrl.project_id is null
    and    mtrl.lpn_id = wlpn.lpn_id
    and    nvl(mtrl.task_id,-9999) = nvl(p_task_id,-9999)
  )
     UNION
     SELECT license_plate_number,
            lpn_id,
            NVL(inventory_item_id, 0),
            NVL(organization_id, 0),
            revision,
            lot_number,
            serial_number,
            subinventory_code,
            NVL(locator_id, 0),
            NVL(parent_lpn_id, 0),
            NVL(sealed_status, 2),
            gross_weight_uom_code,
            NVL(gross_weight, 0),
            content_volume_uom_code,
            NVL(content_volume, 0)
     FROM wms_license_plate_numbers wlpn
     WHERE license_plate_number LIKE (p_lpn)
     and   organization_id = p_org_id
     AND   lpn_context =  1
     and   exists
         ( select inventory_location_id
      from mtl_item_locations mil
      where organization_id = p_org_id
      and   nvl(wlpn.subinventory_code,'@@@') = nvl(mil.subinventory_code,'@@@')
      and   mil.project_id is null
      and   wlpn.locator_id = mil.inventory_location_id
      and   nvl(task_id,-9999) = nvl(p_task_id,-9999)
     )
     AND inv_material_status_grp.is_status_applicable
       ('TRUE',
        NULL,
        INV_GLOBALS.G_TYPE_CONTAINER_PACK,
        NULL,
        NULL,
        p_org_id,
        NULL,
        wlpn.subinventory_code,
        wlpn.locator_id,
        NULL,
        NULL,
        'Z') = 'Y'
       AND inv_material_status_grp.is_status_applicable
       ('TRUE',
        NULL,
        INV_GLOBALS.G_TYPE_CONTAINER_PACK,
        NULL,
        NULL,
        p_org_id,
        NULL,
        wlpn.subinventory_code,
        wlpn.locator_id,
        NULL,
        NULL,
        'L') = 'Y'
     UNION
     SELECT license_plate_number,
            lpn_id,
            NVL(inventory_item_id, 0),
            NVL(organization_id, 0),
            revision,
            lot_number,
            serial_number,
            subinventory_code,
            NVL(locator_id, 0),
            NVL(parent_lpn_id, 0),
            NVL(sealed_status, 2),
            gross_weight_uom_code,
            NVL(gross_weight, 0),
            content_volume_uom_code,
            NVL(content_volume, 0)
     FROM wms_license_plate_numbers wlpn
     WHERE license_plate_number LIKE (p_lpn)
     and   organization_id = p_org_id
     and   (lpn_context = 5 or lpn_id = p_from_lpn_id )
     ORDER BY 1;
   end if;

END GET_RCV_LPN;



PROCEDURE GET_CYC_PARENT_LPN_LOV
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_unscheduled_entry      IN   NUMBER    ,
   p_cycle_count_header_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_project_id             IN   NUMBER    ,
   p_task_id                IN   NUMBER    )
IS
l_container_discrepancy_option   NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Get the cycle count container discrepancy flag
   SELECT NVL(container_discrepancy_option, 2)
     INTO l_container_discrepancy_option
     FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id;

   IF (p_unscheduled_entry = 1) THEN -- Unscheduled entries are allowed
      -- Select all LPN's which exist in the given org, sub, loc
      OPEN x_lpn_lov FOR
 SELECT license_plate_number,
        lpn_id,
        inventory_item_id,
        organization_id,
        revision,
        lot_number,
        serial_number,
        subinventory_code,
        locator_id,
        parent_lpn_id,
        NVL(sealed_status, 2),
        gross_weight_uom_code,
        NVL(gross_weight, 0),
        content_volume_uom_code,
        NVL(content_volume, 0),
        lpn_context             -- Added for resolution of Bug# 4349304. The LPN Context is required by the LOVs called
                                -- by the Cycle Count and Physical Count pages to validate whether the LPN belongs to same
                                --organization, whether the LPN is "Issued out of Stores".
 FROM wms_license_plate_numbers
 WHERE organization_id = p_organization_id
 AND (subinventory_code = p_subinventory_code OR
      l_container_discrepancy_option = 1)
 AND (NVL(locator_id, -99999) = NVL(p_locator_id, -99999) OR
      (l_container_discrepancy_option = 1
              AND locator_id in (
                                   select inventory_location_id
                                   from   mtl_item_locations
                                   where  nvl(segment19,-9999) = nvl(p_project_id,-9999)
                                   and    nvl(segment20,-9999) = nvl(p_task_id,-9999)
                                 )
             )
            )
 AND license_plate_number LIKE (p_lpn)
 --AND lpn_context not in (4,6) --Bug# 4205672  --bug#4267956.Added 6 --Commented for bug#4886188
 ORDER BY license_plate_number;
    ELSE -- Unscheduled entries are not allowed
      -- Select only LPN's that exist in table MTL_CYCLE_COUNT_ENTRIES
      OPEN x_lpn_lov FOR
 SELECT UNIQUE wlpn.license_plate_number,
        wlpn.lpn_id,
        wlpn.inventory_item_id,
        wlpn.organization_id,
        wlpn.revision,
        wlpn.lot_number,
        wlpn.serial_number,
        wlpn.subinventory_code,
        wlpn.locator_id,
        wlpn.parent_lpn_id,
        NVL(wlpn.sealed_status, 2),
        wlpn.gross_weight_uom_code,
        NVL(wlpn.gross_weight, 0),
        wlpn.content_volume_uom_code,
        NVL(wlpn.content_volume, 0),
        wlpn.lpn_context             -- Added for resolution of Bug# 4349304. The LPN Context is required by the LOVs called
                                -- by the Cycle Count and Physical Count pages to validate whether the LPN belongs to same
                                --organization, whether the LPN is "Issued out of Stores".
 FROM wms_license_plate_numbers wlpn,
 mtl_cycle_count_entries mcce
 WHERE wlpn.organization_id = p_organization_id
 AND (wlpn.subinventory_code = p_subinventory_code OR
      l_container_discrepancy_option = 1)
        -- Bug# 1609449
 --AND NVL(wlpn.locator_id, -99999) = NVL(p_locator_id, -99999)
 AND wlpn.license_plate_number LIKE (p_lpn)
 --AND wlpn.lpn_context not in (4,6) --Bug# 4205672  --bug#4267956.Added 6 --Commented for bug#4886188
 AND wlpn.lpn_id = mcce.parent_lpn_id
 AND mcce.organization_id = p_organization_id
 AND mcce.cycle_count_header_id = p_cycle_count_header_id
 AND (mcce.subinventory = p_subinventory_code OR
      l_container_discrepancy_option = 1)
 AND (NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999) OR
      (l_container_discrepancy_option = 1
              AND mcce.locator_id in (
                                   select inventory_location_id
                                   from   mtl_item_locations
                                   where  nvl(segment19,-9999) = nvl(p_project_id,-9999)
                                   and    nvl(segment20,-9999) = nvl(p_task_id,-9999)
                                 )
             )
            )
 AND mcce.entry_status_code IN (1, 3)
 AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD'))
 >= TRUNC(SYSDATE, 'DD');
   END IF;

END GET_CYC_PARENT_LPN_LOV;



PROCEDURE GET_CYC_LPN_LOV
  (x_lpn_lov                OUT  NOCOPY t_genref  ,
   p_lpn                    IN   VARCHAR2  ,
   p_unscheduled_entry      IN   NUMBER    ,
   p_cycle_count_header_id  IN   NUMBER    ,
   p_organization_id        IN   NUMBER    ,
   p_subinventory_code      IN   VARCHAR2  ,
   p_locator_id             IN   NUMBER    ,
   p_parent_lpn_id          IN   NUMBER    ,
   p_project_id             IN   NUMBER    ,
   p_task_id                IN   NUMBER    )
IS
l_container_discrepancy_option   NUMBER;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Get the cycle count container discrepancy flag
   SELECT NVL(container_discrepancy_option, 2)
     INTO l_container_discrepancy_option
     FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = p_cycle_count_header_id;

   IF (p_unscheduled_entry = 1) THEN -- Unscheduled entries are allowed
      -- Select all LPN's which exist in the given org, sub, loc
      OPEN x_lpn_lov FOR
 SELECT license_plate_number,
        lpn_id,
        inventory_item_id,
        organization_id,
        revision,
        lot_number,
        serial_number,
        subinventory_code,
        locator_id,
        parent_lpn_id,
        NVL(sealed_status, 2),
        gross_weight_uom_code,
        NVL(gross_weight, 0),
        content_volume_uom_code,
        NVL(content_volume, 0),
        lpn_context             -- Added for resolution of Bug# 4349304. The LPN Context is required by the LOVs called
                                -- by the Cycle Count and Physical Count pages to validate whether the LPN belongs to same
                                --organization, whether the LPN is "Issued out of Stores".
 FROM wms_license_plate_numbers
 WHERE organization_id = p_organization_id
 AND (subinventory_code = p_subinventory_code OR
      l_container_discrepancy_option = 1)
 AND (NVL(locator_id, -99999) = NVL(p_locator_id, -99999) OR
      (l_container_discrepancy_option = 1
              AND locator_id in (
                                   select inventory_location_id
                                   from   mtl_item_locations
                                   where  nvl(segment19,-9999) = nvl(p_project_id,-9999)
                                   and    nvl(segment20,-9999) = nvl(p_task_id,-9999)
                                 )
             )
            )
        AND license_plate_number LIKE (p_lpn)
        --AND lpn_context not in (4,6) --Bug# 4205672  --bug#4267956.Added 6 --Commented for bug#4886188
 ORDER BY license_plate_number;
    ELSE -- Unscheduled entries are not allowed
      -- Select only LPN's that exist in table MTL_CYCLE_COUNT_ENTRIES
      OPEN x_lpn_lov FOR
 SELECT UNIQUE wlpn.license_plate_number,
        wlpn.lpn_id,
        wlpn.inventory_item_id,
        wlpn.organization_id,
        wlpn.revision,
        wlpn.lot_number,
        wlpn.serial_number,
        wlpn.subinventory_code,
        wlpn.locator_id,
        wlpn.parent_lpn_id,
        NVL(wlpn.sealed_status, 2),
        wlpn.gross_weight_uom_code,
        NVL(wlpn.gross_weight, 0),
        wlpn.content_volume_uom_code,
        NVL(wlpn.content_volume, 0),
        wlpn.lpn_context             -- Added for resolution of Bug# 4349304. The LPN Context is required by the LOVs called
                                -- by the Cycle Count and Physical Count pages to validate whether the LPN belongs to same
                                --organization, whether the LPN is "Issued out of Stores".
 FROM wms_license_plate_numbers wlpn,
 mtl_cycle_count_entries mcce
 WHERE wlpn.organization_id = p_organization_id
 AND (wlpn.subinventory_code = p_subinventory_code OR
      l_container_discrepancy_option = 1)
        -- Bug# 1609449
 --AND NVL(wlpn.locator_id, -99999) = NVL(p_locator_id, -99999)
 AND wlpn.license_plate_number LIKE (p_lpn)
 --AND wlpn.lpn_context not in (4,6) --Bug# 4205672  --bug#4267956.Added 6 --Commented for bug#4886188
 AND wlpn.parent_lpn_id = p_parent_lpn_id
 AND wlpn.lpn_id = mcce.parent_lpn_id
 AND mcce.organization_id = p_organization_id
 AND mcce.cycle_count_header_id = p_cycle_count_header_id
 AND (mcce.subinventory = p_subinventory_code OR
      l_container_discrepancy_option = 1)
 AND (NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999) OR
      (l_container_discrepancy_option = 1
              AND mcce.locator_id in (
                                   select inventory_location_id
                                   from   mtl_item_locations
                                   where  nvl(segment19,-9999) = nvl(p_project_id,-9999)
                                   and    nvl(segment20,-9999) = nvl(p_task_id,-9999)
                                 )
             )
            )
 AND mcce.entry_status_code IN (1, 3)
 AND NVL(TRUNC(mcce.count_due_date, 'DD'), TRUNC(SYSDATE, 'DD'))
 >= TRUNC(SYSDATE, 'DD');
   END IF;

END GET_CYC_LPN_LOV;

/* PJM-WMS Integration:Return only the LPNs residing in physical locators.
 *  Use the table mtl_item_locations instead of mtl_item_locations_kfv.
 *  Use the function  INV_PROJECT.get_locsegs() to retrieve the
 *  concatenated segments.
 */
PROCEDURE GET_CGUPDATE_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_lpn_lov FOR
     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            wlpn.subinventory_code,
            wlpn.locator_id,
            -- PJM-WMS Integration
            INV_PROJECT.GET_LOCSEGS(mil.inventory_location_id,p_org_id)
     FROM mtl_item_locations mil,-- -PJM-WMS Integration
          wms_license_plate_numbers wlpn
     WHERE mil.inventory_location_id = wlpn.locator_id
     AND mil.organization_id = wlpn.organization_id
     AND mil.segment19 is null
       -- bug 2267845 fix. checking this conditon
       -- for identifying non project locators instead of
       -- 'phyiscal_location_id is null'
     AND wlpn.license_plate_number LIKE (p_lpn)
     AND wlpn.organization_id = p_org_id
     AND wlpn.lpn_context = 1
     ORDER BY license_plate_number;

END GET_CGUPDATE_LPN;

PROCEDURE GET_PALLET_LPN_LOV(x_lpn_lov OUT NOCOPY t_genref,
           p_org_id IN NUMBER,
           p_lpn VARCHAR2
           )
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   OPEN x_lpn_lov FOR
   SELECT   wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlpn.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            wlpn.subinventory_code,
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
   /*select license_plate_number,
        wlpn.lpn_id,
        NVL(wlpn.inventory_item_id, 0),
        NVL(wlpn.organization_id, 0),
        wlpn.revision,
        wlpn.lot_number,
        wlpn.serial_number,
        wlpn.subinventory_code,
        NVL(wlpn.locator_id, 0),
        NVL(wlpn.parent_lpn_id, 0),
        NVL(wlpn.sealed_status, 2),
        wlpn.gross_weight_uom_code,
        NVL(wlpn.gross_weight, 0),
        wlpn.content_volume_uom_code,
        NVL(wlpn.content_volume, 0)*/
 FROM   wms_license_plate_numbers wlpn,
        mtl_system_items_kfv msik
 WHERE  wlpn.organization_id = p_org_id
 AND    wlpn.inventory_item_id IS NOT NULL
 AND    msik.inventory_item_id = wlpn.inventory_item_id
 AND    msik.organization_id = wlpn.organization_id
 AND    msik.container_type_code = 'PALLET'
 AND    wlpn.license_plate_number LIKE (p_lpn);
END GET_PALLET_LPN_LOV;

PROCEDURE CHECK_LPN_LOV
    (  p_lpn   IN  VARCHAR2,
  p_organization_id IN  NUMBER,
  x_lpn_id  OUT NOCOPY NUMBER,
  x_inventory_item_id OUT NOCOPY NUMBER,
  x_organization_id OUT NOCOPY NUMBER,
          x_lot_number  OUT NOCOPY VARCHAR2,
  x_revision  OUT NOCOPY VARCHAR2,
  x_serial_number  OUT NOCOPY VARCHAR2,
  x_subinventory  OUT NOCOPY VARCHAR2,
  x_locator_id  OUT NOCOPY NUMBER,
  x_parent_lpn_id  OUT NOCOPY NUMBER,
  x_sealed_status  OUT NOCOPY NUMBER,
  x_gross_weight   OUT NOCOPY NUMBER,
  x_gross_weight_uom_code OUT NOCOPY VARCHAR2,
  x_content_volume OUT NOCOPY NUMBER,
  x_content_volume_uom_code OUT NOCOPY VARCHAR2,
  x_source_type_id OUT NOCOPY NUMBER,
  x_source_header_id OUT NOCOPY NUMBER,
  x_source_name  OUT NOCOPY VARCHAR2,
  x_source_line_id OUT NOCOPY NUMBER,
  x_source_line_detail_id OUT NOCOPY NUMBER,
  x_cost_group_id  OUT NOCOPY NUMBER,
  x_newLPN   OUT NOCOPY VARCHAR2,
  x_concat_segments       OUT NOCOPY VARCHAR2,
  x_context               OUT NOCOPY VARCHAR2,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_data              OUT NOCOPY VARCHAR2,
  p_createnewlpn_flag     IN  VARCHAR2
    )
    IS
 l_flag1  NUMBER:=0;
 l_flag2  NUMBER:=0;
 l_locator_id NUMBER:=-1;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    BEGIN
-- l_flag1 := 0;
-- l_flag2 := 0;

 BEGIN
 SELECT  LPN_ID,
  INVENTORY_ITEM_ID,
  ORGANIZATION_ID,
  LOT_NUMBER,
  REVISION,
  SERIAL_NUMBER,
  SUBINVENTORY_CODE,
  LOCATOR_ID,
  PARENT_LPN_ID,
  SEALED_STATUS,
  GROSS_WEIGHT_UOM_CODE,
  GROSS_WEIGHT,
   CONTENT_VOLUME_UOM_CODE,
   CONTENT_VOLUME,
  SOURCE_TYPE_ID,
  SOURCE_HEADER_ID,
  SOURCE_NAME,
  SOURCE_LINE_ID,
  SOURCE_LINE_DETAIL_ID,
  cost_group_id,
         'FALSE',
  1,
  LOCATOR_ID,
                LPN_CONTEXT
   INTO  x_lpn_id,
  x_inventory_item_id,
  x_organization_id,
          x_lot_number,
  x_revision,
  x_serial_number,
  x_subinventory,
  x_locator_id,
  x_parent_lpn_id,
  x_sealed_status,
  x_gross_weight_uom_code,
  x_gross_weight,
  x_content_volume_uom_code,
  x_content_volume,
  x_source_type_id,
  x_source_header_id,
  x_source_name,
  x_source_line_id,
  x_source_line_detail_id,
  x_cost_group_id,
         x_newLPN,
  l_flag1,
  l_locator_id,
                x_context
  FROM  wms_license_plate_numbers
 WHERE  license_plate_number = p_lpn;

        EXCEPTION
        WHEN no_data_found THEN

  x_newLPN := 'TRUE';
         x_concat_segments := 'NULL';

  -- Create new lpn
  IF (p_createnewlpn_flag = 'TRUE') THEN
   inv_rcv_common_apis.create_lpn(
    p_organization_id,
         p_lpn,
         x_lpn_id,
         x_return_status,
         x_msg_data);
  END IF;

-- return;
 END;

 -- Only get from milk if the locator is not null
 IF (l_flag1 = 1 AND Nvl(l_locator_id,-1)<>-1) THEN
  select  1,
   milk.concatenated_segments
  INTO    l_flag2,
   x_concat_segments
  FROM    wms_license_plate_numbers w,
   mtl_item_locations_kfv milk
  WHERE   w.license_plate_number = p_lpn
  AND  w.locator_id = milk.inventory_location_id
                AND     w.organization_id = milk.organization_id;

  IF l_flag2 = 0 THEN
   x_concat_segments := 'NULL';
  END IF;
 END IF;
END CHECK_LPN_LOV;

/**********************************************************************************
                     WMS - PJM Integration Enhancements
   Differences from CHECK_LPN_LOV
    1. Returns the locator concatenated segments without SEGMENT19 and SEGMENT20.
       by making a call to the procedure INV_PROJECT.GET_LOCSEGS
    2. Returns the Project ID, Project Number, Task ID and Task Number associated
       with the locator by making a call to the package INV_PROJECT.
**********************************************************************************/
PROCEDURE CHECK_PJM_LPN_LOV
    ( p_lpn                      IN  VARCHAR2,
      p_organization_id          IN  NUMBER,
      x_lpn_id                   OUT NOCOPY NUMBER,
      x_inventory_item_id        OUT NOCOPY NUMBER,
      x_organization_id          OUT NOCOPY NUMBER,
      x_lot_number               OUT NOCOPY VARCHAR2,
      x_revision                 OUT NOCOPY VARCHAR2,
      x_serial_number            OUT NOCOPY VARCHAR2,
      x_subinventory             OUT NOCOPY VARCHAR2,
      x_locator_id               OUT NOCOPY NUMBER,
      x_parent_lpn_id            OUT NOCOPY NUMBER,
      x_sealed_status            OUT NOCOPY NUMBER,
      x_gross_weight             OUT NOCOPY NUMBER,
      x_gross_weight_uom_code    OUT NOCOPY VARCHAR2,
      x_content_volume           OUT NOCOPY NUMBER,
      x_content_volume_uom_code  OUT NOCOPY VARCHAR2,
      x_source_type_id           OUT NOCOPY NUMBER,
      x_source_header_id         OUT NOCOPY NUMBER,
      x_source_name              OUT NOCOPY VARCHAR2,
      x_source_line_id           OUT NOCOPY NUMBER,
      x_source_line_detail_id    OUT NOCOPY NUMBER,
      x_cost_group_id            OUT NOCOPY NUMBER,
      x_newLPN                   OUT NOCOPY VARCHAR2,
      x_concat_segments          OUT NOCOPY VARCHAR2,
      x_project_id               OUT NOCOPY VARCHAR2,
      x_project_number           OUT NOCOPY VARCHAR2,
      x_task_id                  OUT NOCOPY VARCHAR2,
      x_task_number              OUT NOCOPY VARCHAR2,
      x_context                  OUT NOCOPY VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_data                 OUT NOCOPY VARCHAR2,
      p_createnewlpn_flag        IN  VARCHAR2
    )
IS
   l_locator_id NUMBER:=-1;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   BEGIN
      SELECT LPN_ID,
             INVENTORY_ITEM_ID,
             ORGANIZATION_ID,
             LOT_NUMBER,
             REVISION,
             SERIAL_NUMBER,
             SUBINVENTORY_CODE,
             LOCATOR_ID,
             PARENT_LPN_ID,
             SEALED_STATUS,
             GROSS_WEIGHT_UOM_CODE,
             GROSS_WEIGHT,
             CONTENT_VOLUME_UOM_CODE,
             CONTENT_VOLUME,
             SOURCE_TYPE_ID,
             SOURCE_HEADER_ID,
             SOURCE_NAME,
             SOURCE_LINE_ID,
             SOURCE_LINE_DETAIL_ID,
             cost_group_id,
             'FALSE',
             LOCATOR_ID,
             LPN_CONTEXT,
             INV_PROJECT.GET_LOCSEGS(LOCATOR_ID,ORGANIZATION_ID),
             INV_PROJECT.GET_PROJECT_ID,
             INV_PROJECT.GET_PROJECT_NUMBER,
             INV_PROJECT.GET_TASK_ID,
             INV_PROJECT.GET_TASK_NUMBER
        INTO x_lpn_id,
             x_inventory_item_id,
             x_organization_id,
             x_lot_number,
             x_revision,
             x_serial_number,
             x_subinventory,
             x_locator_id,
             x_parent_lpn_id,
             x_sealed_status,
             x_gross_weight_uom_code,
             x_gross_weight,
             x_content_volume_uom_code,
             x_content_volume,
             x_source_type_id,
             x_source_header_id,
             x_source_name,
             x_source_line_id,
             x_source_line_detail_id,
             x_cost_group_id,
             x_newLPN,
             l_locator_id,
             x_context,
             x_concat_segments,
             x_project_id,
             x_project_number,
             x_task_id,
             x_task_number
        FROM wms_license_plate_numbers
        WHERE license_plate_number = p_lpn;

   EXCEPTION
      WHEN no_data_found THEN
         x_newLPN := 'TRUE';
         x_concat_segments := 'NULL';
         -- Create new lpn
         IF (p_createnewlpn_flag = 'TRUE') THEN
            inv_rcv_common_apis.create_lpn
            (
               p_organization_id,
               p_lpn,
               x_lpn_id,
               x_return_status,
               x_msg_data
            );
         END IF;
   END;
END CHECK_PJM_LPN_LOV;


PROCEDURE GET_CONTEXT_LPN_LOV
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_organization_id IN   NUMBER,
   p_context IN VARCHAR2,
   p_lpn      IN   VARCHAR2
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   OPEN x_lpn_lov FOR
     SELECT distinct
            license_plate_number,
            lpn_id,
            NVL(inventory_item_id, 0),
            NVL(organization_id, 0),
            revision,
            lot_number,
            serial_number,
            subinventory_code,
            NVL(locator_id, 0),
            NVL(parent_lpn_id, 0),
            NVL(sealed_status, 2),
            gross_weight_uom_code,
            NVL(gross_weight, 0),
            content_volume_uom_code,
            NVL(content_volume, 0)
     FROM wms_license_plate_numbers
     WHERE license_plate_number LIKE (p_lpn)
     AND   organization_id = p_organization_id
     AND  lpn_context = NVL(TO_NUMBER(p_context), lpn_context);

END GET_CONTEXT_LPN_LOV;

--"Returns"
PROCEDURE GET_RETURN_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   OPEN x_lpn_lov FOR
     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlpn.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            'FULL',                     -- Instead of Subinventory
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
     FROM   wms_license_plate_numbers wlpn
     WHERE  wlpn.license_plate_number LIKE (p_lpn)
     AND    wlpn.organization_id = p_org_id
     AND    WMS_RETURN_SV.GET_LPN_MARKED_STATUS(wlpn.lpn_id, wlpn.organization_id)='FULL'
     UNION ALL
     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            NVL(wlpn.inventory_item_id, 0),
            NVL(wlpn.organization_id, 0),
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            'PARTIAL',                  -- Instead of Subinventory
            NVL(wlpn.locator_id, 0),
            NVL(wlpn.parent_lpn_id, 0),
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
     FROM   wms_license_plate_numbers wlpn
     WHERE  wlpn.license_plate_number LIKE (p_lpn)
     AND    wlpn.organization_id = p_org_id
     AND    WMS_RETURN_SV.GET_LPN_MARKED_STATUS(wlpn.lpn_id, wlpn.organization_id)='PARTIAL'
     ORDER BY 1;

END GET_RETURN_LPN;
--"Returns"


PROCEDURE GET_REQEXP_LPN
  (x_lpn_lov                       OUT NOCOPY t_genref ,
   p_lpn                           IN  VARCHAR2        ,
   p_requisition_header_id         IN  VARCHAR2        ,
   p_mode                          IN   VARCHAR2  DEFAULT NULL,
   p_inventory_item_id             IN   VARCHAR2  DEFAULT NULL
)
  IS
     l_req_num          VARCHAR2(10);
     l_progress         VARCHAR2(10);
     l_order_header_id  NUMBER;
     l_debug            NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_progress := '10';
   IF (p_requisition_header_id IS NOT NULL) THEN
      SELECT segment1
 INTO l_req_num
 FROM po_requisition_headers_all
 WHERE requisition_header_id = p_requisition_header_id;
   END IF;

   l_progress := '20';
   SELECT header_id
     INTO   l_order_header_id
     FROM   oe_order_headers_all
     WHERE  orig_sys_document_ref = l_req_num
     AND    order_source_id  = 10;
     --AND    order_type_id    = 1023;

   l_progress := '30';

     -- Nested LPN  changes. Changed this lov to show all child LPNs also.
     -- If Mode is confirm then show only those LPNs with contents, otherwise show all LPNs

     IF p_mode IS NULL THEN
       OPEN x_lpn_lov FOR
       SELECT distinct wlpn.license_plate_number
            ,      wlpn.lpn_id
            ,      count_row.n
       FROM   wsh_delivery_details_ob_grp_v wdd
           ,  wsh_delivery_assignments_v wda
           ,  wsh_delivery_details_ob_grp_v wdd1
            , wms_license_plate_numbers wlpn, (SELECT count(*) n
                                          FROM   wsh_delivery_details_ob_grp_v wdd
                                                  ,  wms_license_plate_numbers wlpn
                                          WHERE wdd.lpn_id in (SELECT wdd.lpn_id
                                                          FROM   wsh_delivery_assignments_v wda
                                                                   , wsh_delivery_details_ob_grp_v wdd
                                                          WHERE  wda.delivery_detail_id in (select  delivery_detail_id
                                                          FROM   wsh_delivery_details_ob_grp_v
                                                          WHERE  source_header_id = l_order_header_id)
                                                          AND    wda.PARENT_DELIVERY_DETAIL_ID = wdd.delivery_detail_id)
                                          AND    wlpn.lpn_context = 6
                                          AND    wlpn.organization_id = wdd.organization_id
                                          AND    wlpn.outermost_lpn_id = NVL(wdd.lpn_id, -9999)) count_row
        WHERE  wdd.source_header_id = l_order_header_id
        AND    wdd.delivery_detail_id = wda.delivery_detail_id
        AND    wdd1.delivery_detail_id = wda.PARENT_DELIVERY_DETAIL_ID
        AND    wlpn.lpn_context = 6
        AND    wlpn.organization_id = wdd1.organization_id
        AND    wlpn.outermost_lpn_id = NVL(wdd1.lpn_id, -9999)
        AND   wlpn.license_plate_number LIKE (p_lpn)
        ORDER BY wlpn.license_plate_number;
     ELSIF   p_mode = 'E' THEN
      /* OPEN x_lpn_lov FOR
       SELECT distinct wlpn.license_plate_number
     ,      wlpn.lpn_id
     ,      count_row.n
       FROM   wsh_delivery_details_ob_grp_v wdd
    ,  wsh_delivery_assignments_v wda
    ,  wsh_delivery_details_ob_grp_v wdd1
     , wms_license_plate_numbers wlpn, (SELECT count(*) n
       FROM   wsh_delivery_details_ob_grp_v wdd
         ,  wms_license_plate_numbers wlpn
       WHERE wdd.lpn_id in (SELECT wdd.lpn_id
         FROM   wsh_delivery_assignments_v wda
           , wsh_delivery_details_ob_grp_v wdd
         WHERE  wda.delivery_detail_id in (select  delivery_detail_id
         FROM   wsh_delivery_details_ob_grp_v
         WHERE  source_header_id = l_order_header_id)
         AND    wda.PARENT_DELIVERY_DETAIL_ID = wdd.delivery_detail_id)
       AND    wlpn.lpn_context = 6
       AND    wlpn.organization_id = wdd.organization_id
       AND    wlpn.lpn_id = NVL(wdd.lpn_id, -9999)) count_row
        WHERE  wdd.source_header_id = l_order_header_id
        AND    wdd.delivery_detail_id = wda.delivery_detail_id
        AND    wdd1.delivery_detail_id = wda.PARENT_DELIVERY_DETAIL_ID
        AND    wlpn.lpn_context = 6
        AND    wlpn.organization_id = wdd1.organization_id
        AND    wlpn.lpn_id = NVL(wdd1.lpn_id, -9999)
        AND   wlpn.license_plate_number LIKE (p_lpn)
        ORDER BY wlpn.license_plate_number;*/

       -- Getting Count is deprecated from Patchset J We will get count from the validation logic itself.
       OPEN x_lpn_lov FOR
         SELECT distinct wln.license_plate_number
     ,      wln.lpn_id
     ,      1
         FROM  wms_license_plate_numbers wln,
               wsh_delivery_details_ob_grp_v wdd
         WHERE wln.lpn_context= 6
         AND   wln.lpn_id = wdd.lpn_id
         AND   wln.license_plate_number LIKE (p_lpn)
         ORDER BY wln.license_plate_number;

     ELSIF p_mode = 'C' THEN
       -- This is changed based on Item Info, case for Item Initiated Receipt.
       -- If Item info is present or passed from the UI then LPN should be restrcied based on Item
       -- Otherwise all the LPN's for the shipment should be displayed in the LOV

       if p_inventory_item_id is null then
         OPEN x_lpn_lov FOR
         SELECT distinct wlpn.license_plate_number
       ,      wlpn.lpn_id
       ,      count_row.n
         FROM   wsh_delivery_details_ob_grp_v wdd
      ,  wsh_delivery_assignments_v wda
      ,  wsh_delivery_details_ob_grp_v wdd1
         , wms_license_plate_numbers wlpn, (SELECT count(*) n
       FROM   wsh_delivery_details_ob_grp_v wdd
         ,  wms_license_plate_numbers wlpn
       WHERE wdd.lpn_id in (SELECT wdd.lpn_id
         FROM   wsh_delivery_assignments_v wda
           , wsh_delivery_details_ob_grp_v wdd
         WHERE  wda.delivery_detail_id in (select  delivery_detail_id
         FROM   wsh_delivery_details_ob_grp_v
                    WHERE  source_header_id = l_order_header_id)
         AND    wda.PARENT_DELIVERY_DETAIL_ID = wdd.delivery_detail_id)
       AND    wlpn.lpn_context = 6
       AND    wlpn.organization_id = wdd.organization_id
                                        -- Nested LPN changes
                                        AND EXISTS (SELECT parent_lpn_id
                                                    FROM wms_lpn_contents wlc
                                                    WHERE parent_lpn_id = wlpn.lpn_id)
       AND    wlpn.lpn_id = NVL(wdd.lpn_id, -9999)) count_row
          WHERE  wdd.source_header_id = l_order_header_id
          AND    wdd.delivery_detail_id = wda.delivery_detail_id
          AND    wdd1.delivery_detail_id = wda.PARENT_DELIVERY_DETAIL_ID
          AND    wlpn.lpn_context = 6
          AND    wlpn.organization_id = wdd1.organization_id
          AND    wlpn.lpn_id = NVL(wdd1.lpn_id, -9999)
          AND   wlpn.license_plate_number LIKE (p_lpn)
          -- Nested LPN changes
          AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents wlc WHERE parent_lpn_id = wlpn.lpn_id)
          ORDER BY wlpn.license_plate_number;
       Else
          OPEN x_lpn_lov FOR
          SELECT distinct wlpn.license_plate_number
        ,      wlpn.lpn_id
        ,      count_row.n
          FROM   wsh_delivery_details_ob_grp_v wdd
       ,  wsh_delivery_assignments_v wda
       ,  wsh_delivery_details_ob_grp_v wdd1
        , wms_license_plate_numbers wlpn, (SELECT count(*) n
       FROM   wsh_delivery_details_ob_grp_v wdd
         ,  wms_license_plate_numbers wlpn
       WHERE wdd.lpn_id in (SELECT wdd.lpn_id
         FROM   wsh_delivery_assignments_v wda
           , wsh_delivery_details_ob_grp_v wdd
         WHERE  wda.delivery_detail_id in (select  delivery_detail_id
         FROM   wsh_delivery_details_ob_grp_v
                    WHERE  source_header_id = l_order_header_id)
         AND    wda.PARENT_DELIVERY_DETAIL_ID = wdd.delivery_detail_id)
       AND    wlpn.lpn_context = 6
       AND    wlpn.organization_id = wdd.organization_id
                                        -- Nested LPN changes
                                        AND EXISTS (SELECT parent_lpn_id
                                                    FROM wms_lpn_contents wlc
                                                    WHERE parent_lpn_id = wlpn.lpn_id)
       AND    wlpn.lpn_id = NVL(wdd.lpn_id, -9999)) count_row
           WHERE  wdd.source_header_id = l_order_header_id
           AND    wdd.delivery_detail_id = wda.delivery_detail_id
           AND    wdd1.delivery_detail_id = wda.PARENT_DELIVERY_DETAIL_ID
           AND    wlpn.lpn_context = 6
           AND    wlpn.organization_id = wdd1.organization_id
           AND    wlpn.lpn_id = NVL(wdd1.lpn_id, -9999)
           AND   wlpn.license_plate_number LIKE (p_lpn)
           -- Nested LPN changes
           AND EXISTS (SELECT parent_lpn_id FROM wms_lpn_contents wlc WHERE parent_lpn_id = wlpn.lpn_id
                                                         and wlc.inventory_item_id = p_inventory_item_id)
           ORDER BY wlpn.license_plate_number;
       End if;
     END IF;

 END GET_REQEXP_LPN;


PROCEDURE GET_UPDATE_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

 OPEN x_lpn_lov FOR
  SELECT license_plate_number,
  lpn_id,
  inventory_item_id,
  organization_id,
  revision,
  lot_number,
  serial_number,
  subinventory_code,
  locator_id,
  parent_lpn_id,
  NVL(sealed_status, 2),
  gross_weight_uom_code,
  NVL(gross_weight, 0),
  content_volume_uom_code,
  NVL(content_volume, 0),
  lpn_context  --Added for Bug#6504032
  FROM wms_license_plate_numbers wlpn
  WHERE wlpn.organization_id = p_org_id
  AND wlpn.license_plate_number LIKE (p_lpn)
  AND wlpn.lpn_context IN (1, 2, 3 , 5, 8, 11); --Inventory, pregenerated, picked contexts /*Resides in WIP(2) added for bug#3953941*/
      -- Added 3 to pick LPNS in status 'Resides n Receiving' Bug 5501058
      --Added context 8 for Bug#6870562
END GET_UPDATE_LPN;



PROCEDURE GET_RECONFIG_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2)
IS
BEGIN

   OPEN x_lpn_lov FOR
 select distinct  outer.license_plate_number,
   outer.subinventory_code,
   milk.concatenated_segments,
   outer.locator_id,
   outer.lpn_id,
   outer.lpn_context,
                 NVL(outer.sealed_status, 2),
                 outer.gross_weight_uom_code,
                 NVL(outer.gross_weight, 0),
   outer.content_volume_uom_code,
   NVL(outer.content_volume, 0)
 from wms_license_plate_numbers outer, wms_license_plate_numbers inner,
      mtl_item_locations_kfv milk
 where inner.outermost_lpn_id <> inner.lpn_id
  AND inner.outermost_lpn_id = outer.lpn_id
  AND outer.locator_id = milk.inventory_location_id(+)
  and outer.lpn_context in (1, 11)
  and outer.organization_id = p_org_id
         and outer.license_plate_number LIKE (p_lpn);
END GET_RECONFIG_LPN;




FUNCTION SUB_LPN_CONTROLLED(p_subinventory_code IN VARCHAR2,
                            p_org_id IN NUMBER)
RETURN VARCHAR2
IS
 l_ret_val VARCHAR2(1) := 'Y';
 l_lpn_cf_flag NUMBER;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  IF (p_subinventory_code IS NULL) THEN
    RETURN 'Y';
  ELSE
    SELECT lpn_controlled_flag
    INTO l_lpn_cf_flag
    FROM MTL_SECONDARY_INVENTORIES msi
    WHERE msi.organization_id = p_org_id
    AND msi.secondary_inventory_name = p_subinventory_code;

    IF ((l_lpn_cf_flag) IS NULL OR (l_lpn_cf_flag = 2)) THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;
  END IF;

END SUB_LPN_CONTROLLED;

PROCEDURE GET_BULK_PACK_LPN
  (x_lpn_lov  OUT  NOCOPY t_genref,
   p_org_id   IN   NUMBER,
   p_lpn      IN   VARCHAR2,
   p_subinventory IN VARCHAR2,
   p_locator      IN NUMBER
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  OPEN x_lpn_lov FOR
    SELECT license_plate_number,
    lpn_id,
    inventory_item_id,
    organization_id,
    revision,
    lot_number,
    serial_number,
    subinventory_code,
    locator_id,
    parent_lpn_id,
    NVL(sealed_status, 2),
    gross_weight_uom_code,
    NVL(gross_weight, 0),
    content_volume_uom_code,
    NVL(content_volume, 0)
    FROM wms_license_plate_numbers wlpn
    WHERE wlpn.organization_id = p_org_id
    AND wlpn.license_plate_number LIKE (p_lpn)
    AND wlpn.subinventory_code = nvl(p_subinventory,wlpn.subinventory_Code)
    AND wlpn.locator_id = decode(p_locator,0,wlpn.locator_id,p_locator)
    AND wlpn.inventory_item_id is not null
    AND wlpn.lpn_id NOT IN ( select content_lpn_id from mtl_material_transactions_temp where content_lpn_id =  wlpn.lpn_id)
    AND wlpn.parent_lpn_id is null
    AND wlpn.lpn_context = 1
  ORDER BY license_plate_number; --Inventory
END GET_BULK_PACK_LPN;


PROCEDURE Get_Picked_Split_From_LPNs(
  x_lpn_lov         OUT NOCOPY t_genref
, p_organization_id IN         NUMBER
, p_lpn_id          IN         VARCHAR2
) IS
BEGIN
  open x_lpn_lov for
    SELECT wlpn.license_plate_number,
           wlpn.lpn_id,
           NVL(wlpn.inventory_item_id, 0),
           NVL(wlpn.organization_id, 0),
           wlpn.revision,
           wlpn.lot_number,
           wlpn.serial_number,
           wlpn.subinventory_code,
           NVL(wlpn.locator_id, 0),
           NVL(wlpn.parent_lpn_id, 0),
           NVL(wlpn.sealed_status, 2),
           wlpn.gross_weight_uom_code,
           NVL(wlpn.gross_weight, 0),
           wlpn.content_volume_uom_code,
           NVL(wlpn.content_volume, 0),
           wdd.delivery_detail_id
    FROM   wms_license_plate_numbers wlpn,
           wsh_delivery_details wdd
    WHERE  wlpn.organization_id = p_organization_id
    AND    wlpn.lpn_context = 11
    AND    wlpn.license_plate_number LIKE (p_lpn_id)
    AND    wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_organization_id) ='Y'
    AND    inv_material_status_grp.is_status_applicable (
             'TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_SPLIT, NULL,
             NULL, p_organization_id, NULL, wlpn.subinventory_code,
             wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
    AND    inv_material_status_grp.is_status_applicable (
             'TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_SPLIT, NULL,
             NULL, p_organization_id, NULL, wlpn.subinventory_code,
             wlpn.locator_id, NULL, NULL, 'L') = 'Y'
    AND    wdd.lpn_id = wlpn.lpn_id
    AND    wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
    ORDER BY license_plate_number;
END Get_Picked_Split_From_LPNs;

--RTV Change 16197273
--New navigation is created for split,under Inbound flow.
--Created new prceedures for from and to_lpn fields specific for RTV ER.

PROCEDURE Get_Return_Split_From_LPNs(
  x_lpn_lov         OUT NOCOPY t_genref
, p_organization_id IN         NUMBER
, p_lpn_id          IN         VARCHAR2
) IS

l_rtv_shipment_flag VARCHAR2(1) := NVL(FND_PROFILE.VALUE('RCV_CREATE_SHIPMENT_FOR_RETURNS'),'N');

BEGIN

if l_rtv_shipment_flag = 'Y' then

  open x_lpn_lov for
    SELECT wlpn.license_plate_number,
           wlpn.lpn_id,
           NVL(wlpn.inventory_item_id, 0),
           NVL(wlpn.organization_id, 0),
           wlpn.revision,
           wlpn.lot_number,
           wlpn.serial_number,
           wlpn.subinventory_code,
           NVL(wlpn.locator_id, 0),
           NVL(wlpn.parent_lpn_id, 0),
           NVL(wlpn.sealed_status, 2),
           wlpn.gross_weight_uom_code,
           NVL(wlpn.gross_weight, 0),
           wlpn.content_volume_uom_code,
           NVL(wlpn.content_volume, 0),
           wdd.delivery_detail_id
    FROM   wms_license_plate_numbers wlpn,
           wsh_delivery_details wdd ,
           wms_lpn_contents wlc
    WHERE  wlpn.organization_id = p_organization_id
    AND    wlpn.lpn_id = wlc.parent_lpn_id
    AND    wlpn.lpn_context = WMS_Container_PUB.LPN_CONTEXT_INV
    AND    wlc.source_name IS NOT null
    AND    wlpn.license_plate_number LIKE (p_lpn_id)
    AND    wms_lpn_lovs.SUB_LPN_CONTROLLED(wlpn.subinventory_code, p_organization_id) ='Y'
    AND    inv_material_status_grp.is_status_applicable (
             'TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_SPLIT, NULL,
             NULL, p_organization_id, NULL, wlpn.subinventory_code,
             wlpn.locator_id, NULL, NULL, 'Z') = 'Y'
    AND    inv_material_status_grp.is_status_applicable (
             'TRUE', NULL, INV_GLOBALS.G_TYPE_CONTAINER_SPLIT, NULL,
             NULL, p_organization_id, NULL, wlpn.subinventory_code,
             wlpn.locator_id, NULL, NULL, 'L') = 'Y'
    AND    wdd.lpn_id = wlpn.lpn_id
    AND    wdd.released_status = 'X'  -- For LPN reuse ER : 6845650
    ORDER BY license_plate_number;

	ELSE

    open x_lpn_lov for
    SELECT NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL
    FROM   dual where 1=2;


END IF ;

END Get_Return_Split_From_LPNs;

--RTV Change 16197273

PROCEDURE Get_Return_Split_To_LPNs(
  x_lpn_lov         OUT NOCOPY t_genref
, p_organization_id IN         NUMBER
, p_lpn_id          IN         VARCHAR2
) IS

BEGIN
  open x_lpn_lov for
    SELECT wlpn.license_plate_number,
           wlpn.lpn_id

    FROM   wms_license_plate_numbers wlpn
    WHERE  wlpn.organization_id = p_organization_id
    AND    wlpn.license_plate_number LIKE (p_lpn_id)
    AND    wlpn.lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED
    ORDER BY license_plate_number;

END Get_Return_Split_To_LPNs;


PROCEDURE get_item_load_lpn_lov
  (x_lpn_lov              OUT   NOCOPY t_genref   ,
   p_organization_id      IN    NUMBER            ,
   p_lpn_id               IN    NUMBER            ,
   p_lpn_context          IN    NUMBER            ,
   p_employee_id          IN    NUMBER            ,
   p_into_lpn             IN    VARCHAR2)
  IS
BEGIN

   -- If an LPN does not have the pregenerated LPN context and matches
   -- the LPN context of the source LPN, it must either be empty or
   -- be an LPN loaded for putaway by the same user/employee.
   OPEN x_lpn_lov FOR
     SELECT wlpn.license_plate_number,
            wlpn.lpn_id,
            wlpn.inventory_item_id,
            wlpn.organization_id,
            wlpn.revision,
            wlpn.lot_number,
            wlpn.serial_number,
            wlpn.subinventory_code,
            wlpn.locator_id,
            wlpn.parent_lpn_id,
            NVL(wlpn.sealed_status, 2),
            wlpn.gross_weight_uom_code,
            NVL(wlpn.gross_weight, 0),
            wlpn.content_volume_uom_code,
            NVL(wlpn.content_volume, 0)
     FROM wms_license_plate_numbers wlpn
     WHERE wlpn.organization_id = p_organization_id
     AND wlpn.lpn_id <> p_lpn_id
     AND (wlpn.lpn_context = WMS_CONTAINER_PUB.LPN_CONTEXT_PREGENERATED
   OR (wlpn.lpn_context = p_lpn_context
       AND ( (NOT EXISTS (SELECT 'LPN_HAS_MATERIAL'
     FROM wms_lpn_contents
     WHERE parent_lpn_id IN (SELECT wlpn1.lpn_id
        FROM
        wms_license_plate_numbers wlpn1
        START WITH
        wlpn1.lpn_id =
        wlpn.outermost_lpn_id
        CONNECT BY PRIOR
        wlpn1.lpn_id = wlpn1.parent_lpn_id)))
      OR
      (EXISTS (SELECT 'LOADED_BY_SAME_USER'
        FROM  mtl_material_transactions_temp mmtt,
        wms_dispatched_tasks wdt
        WHERE mmtt.organization_id = p_organization_id
        AND mmtt.transaction_temp_id = wdt.transaction_temp_id
        AND wdt.organization_id = p_organization_id
        AND wdt.task_type = 2
        AND wdt.status = 4
        AND wdt.person_id = p_employee_id
        AND mmtt.lpn_id IN (SELECT lpn_id
       FROM wms_license_plate_numbers
       START WITH lpn_id = wlpn.outermost_lpn_id
       CONNECT BY PRIOR lpn_id = parent_lpn_id
       )
        )
       )
     )
       )
   )
     AND wlpn.license_plate_number LIKE (p_into_lpn)
     AND inv_material_status_grp.is_status_applicable('TRUE',
            NULL,
            INV_GLOBALS.G_TYPE_CONTAINER_PACK,
            NULL,
            NULL,
            p_organization_id,
            NULL,
            wlpn.subinventory_code,
            wlpn.locator_id,
            NULL,
            NULL,
            'Z') = 'Y'
     AND inv_material_status_grp.is_status_applicable('TRUE',
            NULL,
            INV_GLOBALS.G_TYPE_CONTAINER_PACK,
            NULL,
            NULL,
            p_organization_id,
            NULL,
            wlpn.subinventory_code,
            wlpn.locator_id,
            NULL,
            NULL,
            'L') = 'Y'
     ORDER BY wlpn.license_plate_number;

END get_item_load_lpn_lov;

PROCEDURE get_from_gtmp_lov
  (x_lpn_lov              OUT   NOCOPY t_genref   ,
   p_organization_id      IN    NUMBER            ,
   p_drop_type            IN    VARCHAR2          ,
   p_lpn_name             IN    VARCHAR2
   )
  IS


BEGIN

   OPEN x_lpn_lov FOR
   SELECT DISTINCT
     wlpn.license_plate_number, wlpn.lpn_id,
     NVL (wlpn.inventory_item_id, 0),
     NVL (wlpn.organization_id, 0),
     wlpn.revision,
     wlpn.lot_number,
     wlpn.serial_number,
     wlpn.subinventory_code,
     NVL (wlpn.locator_id, 0),
     NVL (wlpn.parent_lpn_id, 0),
     NVL (wlpn.sealed_status, 2),
     wlpn.gross_weight_uom_code,
     NVL (wlpn.gross_weight, 0),
     wlpn.content_volume_uom_code,
     NVL (wlpn.content_volume, 0),
     milk.concatenated_segments,
     wlpn.lpn_context
   FROM wms_license_plate_numbers wlpn,
     mtl_item_locations_kfv milk,
     wms_putaway_group_tasks_gtmp wpgt
   WHERE wlpn.organization_id = TO_NUMBER (p_organization_id)
     AND wlpn.organization_id = milk.organization_id(+)
     AND wlpn.locator_id = milk.inventory_location_id(+)
     AND wlpn.lpn_id = wpgt.lpn_id
     AND wpgt.row_type = 'Group Task'
     AND drop_type = p_drop_type
     AND wlpn.license_plate_number LIKE p_lpn_name
   ORDER BY wlpn.license_plate_number;
END get_from_gtmp_lov;

-- Procedure to get lpns in status 5 and 1 for the org, sub,locator combination. For bug 12853197
 PROCEDURE GET_PICK_DROP_SUBXFR_LPN_LOV
   (x_lpn_lov         OUT NOCOPY  t_genref       ,
	p_lpn             IN          VARCHAR2       ,
	p_pick_to_lpn_id  IN          NUMBER         ,
	p_org_id          IN          NUMBER         ,
	p_drop_sub        IN          VARCHAR2       ,
	p_drop_loc        IN          NUMBER
   )
   -- passed p_drop_sub and p_drop_loc --vipartha
 IS
	l_lpn    VARCHAR2(50);
	l_debug  NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

 BEGIN

	IF p_lpn IS NOT NULL then
	   l_lpn := p_lpn;
	 ELSE
	   l_lpn := '%';
	END IF;

	OPEN x_lpn_lov FOR
	  SELECT DISTINCT wlpn.license_plate_number
			  , wlpn.lpn_id
			  , NVL(wlpn.inventory_item_id, 0)
			  , NVL(wlpn.organization_id, 0)
			  , wlpn.revision
			  , wlpn.lot_number
			  , wlpn.serial_number
			  , wlpn.subinventory_code
			  , NVL(wlpn.locator_id, 0)
			  , NVL(wlpn.parent_lpn_id, 0)
			  , NVL(wlpn.sealed_status, 2)
			  , wlpn.gross_weight_uom_code
			  , NVL(wlpn.gross_weight, 0)
			  , wlpn.content_volume_uom_code
			  , NVL(wlpn.content_volume, 0)
			  , milk.concatenated_segments
			  , wlpn.lpn_context
		   FROM wms_license_plate_numbers  wlpn
			  , mtl_item_locations_kfv     milk
		 WHERE wlpn.organization_id   = milk.organization_id       (+)
		   AND wlpn.locator_id        = milk.inventory_location_id (+)
		   AND wlpn.outermost_lpn_id  = wlpn.lpn_id
		   AND wlpn.lpn_context       = 1
		   AND wlpn.subinventory_code = p_drop_sub
		   AND wlpn.locator_id        = p_drop_loc
		   AND wlpn.license_plate_number LIKE l_lpn
		   AND wlpn.organization_id   = p_org_id
  /*         AND WMS_Container2_PUB.validate_pick_drop_lpn
			   ( 1.0
			   , 'F'
			   , p_pick_to_lpn_id
			   , p_org_id
			   , wlpn.license_plate_number
			   , p_drop_sub
			   , p_drop_loc
			   ) = 1          */
		   UNION
		   SELECT DISTINCT wlpn.license_plate_number
			  , wlpn.lpn_id
			  , NVL(wlpn.inventory_item_id, 0)
			  , NVL(wlpn.organization_id, 0)
			  , wlpn.revision
			  , wlpn.lot_number
			  , wlpn.serial_number
			  , wlpn.subinventory_code
			  , NVL(wlpn.locator_id, 0)
			  , NVL(wlpn.parent_lpn_id, 0)
			  , NVL(wlpn.sealed_status, 2)
			  , wlpn.gross_weight_uom_code
			  , NVL(wlpn.gross_weight, 0)
			  , wlpn.content_volume_uom_code
			  , NVL(wlpn.content_volume, 0)
			  , milk.concatenated_segments
			  , wlpn.lpn_context
		   FROM wms_license_plate_numbers  wlpn
			  , mtl_item_locations_kfv     milk
		 WHERE wlpn.organization_id   = milk.organization_id       (+)
		   AND wlpn.locator_id        = milk.inventory_location_id (+)
		   AND wlpn.outermost_lpn_id  = wlpn.lpn_id
		   AND wlpn.lpn_context       = 5
		   AND wlpn.license_plate_number LIKE l_lpn
		   AND wlpn.organization_id   = p_org_id
		 ORDER BY license_plate_number;

 END GET_PICK_DROP_SUBXFR_LPN_LOV;

END WMS_LPN_LOVS;

/

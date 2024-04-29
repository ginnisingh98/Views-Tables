--------------------------------------------------------
--  DDL for Package Body INV_CYC_SERIALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CYC_SERIALS" AS
/* $Header: INVCYCMB.pls 120.2 2005/08/22 11:59:29 pojha noship $ */


   PROCEDURE print_debug (
         p_err_msg VARCHAR2
      )
      IS
         l_debug   NUMBER := NVL ( FND_PROFILE.VALUE ( 'INV_DEBUG_TRACE' ), 0 );
      BEGIN
         IF ( l_debug = 1 ) THEN
            inv_mobile_helper_functions.tracelog ( p_err_msg           => p_err_msg,
                                                   p_module            => 'INV_CYC_SERIALS',
                                                   p_level             => 4
                                                 );
         END IF;
   --   dbms_output.put_line(p_err_msg);
      END print_debug;

PROCEDURE get_scheduled_serial_lov
  (x_serials                 OUT NOCOPY t_genref          ,
   p_organization_id         IN         NUMBER            ,
   p_subinventory            IN         VARCHAR2          ,
   p_locator_id              IN         NUMBER   := NULL  ,
   p_inventory_item_id       IN         NUMBER            ,
   p_revision                IN         VARCHAR2 := NULL  ,
   p_lot_number              IN         VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN         NUMBER            ,
   p_parent_lpn_id           IN         NUMBER   := NULL)
IS

BEGIN
   -- Multiple serial that are scheduled
   OPEN x_serials FOR
     SELECT UNIQUE msn.serial_number,
     msn.current_subinventory_code,
     msn.current_locator_id,
     msn.lot_number,
     0,
     msn.current_status,
     mms.status_code
     FROM mtl_serial_numbers msn, mtl_cc_serial_numbers mcsn,
     mtl_material_statuses_vl mms, mtl_cycle_count_entries mcce
     WHERE msn.inventory_item_id = p_inventory_item_id
     AND msn.current_organization_id = p_organization_id
     AND msn.current_status IN (1, 3)
     AND msn.status_id = mms.status_id(+)
     AND msn.serial_number = mcsn.serial_number
     AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
     AND mcce.cycle_count_header_id = p_cycle_count_header_id
     AND mcce.inventory_item_id = p_inventory_item_id
     AND mcce.organization_id = p_organization_id
     AND mcce.subinventory = p_subinventory
     AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
     AND NVL(mcce.revision, '@@@@@') = NVL(p_revision, '@@@@@')
     AND NVL(mcce.lot_number, '###' ) = NVL(p_lot_number, '###')
     AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
     AND mcce.entry_status_code IN (1, 3)
     AND NVL(mcce.export_flag, 2) = 2
     ORDER BY LPAD(msn.serial_number, 20);

END get_scheduled_serial_lov;


PROCEDURE get_serial_entry_lov
  (x_serials                 OUT   NOCOPY t_genref          ,
   p_organization_id         IN           NUMBER            ,
   p_subinventory            IN           VARCHAR2          ,
   p_locator_id              IN           NUMBER   := NULL  ,
   p_inventory_item_id       IN           NUMBER            ,
   p_revision                IN           VARCHAR2 := NULL  ,
   p_lot_number              IN           VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN           NUMBER            ,
   p_parent_lpn_id           IN           NUMBER   := NULL)
IS

BEGIN
   -- Multiple serial that are selected as existing already
   OPEN x_serials FOR
     SELECT UNIQUE msn.serial_number,
     msn.current_subinventory_code,
     msn.current_locator_id,
     msn.lot_number,
     0,
     msn.current_status,
     mms.status_code
     FROM mtl_serial_numbers msn, mtl_cc_serial_numbers mcsn,
     mtl_material_statuses_vl mms, mtl_cycle_count_entries mcce
     WHERE msn.inventory_item_id = p_inventory_item_id
     AND msn.group_mark_id = 1
     AND msn.current_organization_id = p_organization_id
     AND msn.current_status IN (1, 3)
     AND msn.status_id = mms.status_id(+)
     AND msn.serial_number = mcsn.serial_number
     AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
     AND mcce.cycle_count_header_id = p_cycle_count_header_id
     AND mcce.inventory_item_id = p_inventory_item_id
     AND mcce.organization_id = p_organization_id
     AND mcce.subinventory = p_subinventory
     AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
     AND NVL(mcce.revision, '@@@@@') = NVL(p_revision, '@@@@@')
     AND NVL(mcce.lot_number, '###' ) = NVL(p_lot_number, '###')
     AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
     AND mcce.entry_status_code IN (1, 3)
     AND NVL(mcce.export_flag, 2) = 2
     AND  NVL ( mcce.number_of_counts , 0 ) = NVL ( mcsn.number_of_counts , 0 ) -- Bug 4533713
     ORDER BY LPAD(msn.serial_number, 20);

END get_serial_entry_lov;


PROCEDURE initialize_scheduled_serials
  (p_organization_id         IN    NUMBER            ,
   p_subinventory            IN    VARCHAR2          ,
   p_locator_id              IN    NUMBER   := NULL  ,
   p_inventory_item_id       IN    NUMBER            ,
   p_revision                IN    VARCHAR2 := NULL  ,
   p_lot_number              IN    VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN    NUMBER            ,
   p_parent_lpn_id           IN    NUMBER   := NULL)
IS

BEGIN
   -- Multiple serial that are scheduled
   UPDATE mtl_serial_numbers
     SET group_mark_id = -1
     WHERE inventory_item_id = p_inventory_item_id
     AND current_organization_id = p_organization_id
     AND serial_number IN
     (SELECT UNIQUE msn.serial_number
      FROM mtl_serial_numbers msn, mtl_cc_serial_numbers mcsn,
      mtl_material_statuses_vl mms, mtl_cycle_count_entries mcce
      WHERE msn.inventory_item_id = p_inventory_item_id
      AND msn.current_organization_id = p_organization_id
      AND msn.current_status IN (1, 3)
      AND msn.status_id = mms.status_id(+)
      AND msn.serial_number = mcsn.serial_number
      AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
      AND mcce.cycle_count_header_id = p_cycle_count_header_id
      AND mcce.inventory_item_id = p_inventory_item_id
      AND mcce.organization_id = p_organization_id
      AND mcce.subinventory = p_subinventory
      AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
      AND NVL(mcce.revision, '@@@@@') = NVL(p_revision, '@@@@@')
      AND NVL(mcce.lot_number, '###' ) = NVL(p_lot_number, '###')
      AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
      AND mcce.entry_status_code IN (1, 3)
      AND NVL(mcce.export_flag, 2) = 2);

END initialize_scheduled_serials;


PROCEDURE mark_serial
  (p_organization_id         IN    NUMBER            ,
   p_subinventory            IN    VARCHAR2          ,
   p_locator_id              IN    NUMBER   := NULL  ,
   p_inventory_item_id       IN    NUMBER            ,
   p_revision                IN    VARCHAR2 := NULL  ,
   p_lot_number              IN    VARCHAR2 := NULL  ,
   p_serial_number           IN    VARCHAR2          ,
   p_parent_lpn_id           IN    NUMBER   := NULL  ,
   p_cycle_count_header_id   IN    NUMBER            ,
   x_return_code             OUT NOCOPY  NUMBER)
IS
l_exist_temp                 NUMBER;
l_cycle_count_entry_id       NUMBER;
l_approval_condition         NUMBER;

BEGIN
   -- Initialize the return code
   x_return_code := 0;

   -- First check if the multiple serial entry exists
   SELECT COUNT(*)
     INTO l_exist_temp
     FROM DUAL
     WHERE EXISTS
     (SELECT 'multiple-serial'
      FROM mtl_serial_numbers
      WHERE inventory_item_id = p_inventory_item_id
      AND current_organization_id = p_organization_id
      AND serial_number IN
      (SELECT UNIQUE msn.serial_number
       FROM mtl_serial_numbers msn, mtl_cc_serial_numbers mcsn,
       mtl_material_statuses_vl mms, mtl_cycle_count_entries mcce
       WHERE msn.inventory_item_id = p_inventory_item_id
       AND msn.current_organization_id = p_organization_id
       AND (   msn.current_status IN (1, 3)
            OR (msn.last_txn_source_type_id = 9 AND msn.current_status = 4)) --Bug# 3595723
       AND msn.status_id = mms.status_id(+)
       AND msn.serial_number = p_serial_number
       AND msn.serial_number = mcsn.serial_number
       AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
       AND mcce.cycle_count_header_id = p_cycle_count_header_id
       AND mcce.inventory_item_id = p_inventory_item_id
       AND mcce.organization_id = p_organization_id
       AND mcce.subinventory = p_subinventory
       AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
       AND NVL(mcce.revision, '@@@@@') = NVL(p_revision, '@@@@@')
       AND NVL(mcce.lot_number, '###' ) = NVL(p_lot_number, '###')
       AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
       AND mcce.entry_status_code IN (1, 3)
       AND NVL(mcce.export_flag, 2) = 2));

   print_debug('l_exist_temp = ' || l_exist_temp);

   IF (l_exist_temp <> 0) THEN
      -- The serial number entry exists and can be marked
      UPDATE mtl_serial_numbers
	SET group_mark_id = 1
	WHERE inventory_item_id = p_inventory_item_id
	AND current_organization_id = p_organization_id
	AND serial_number = p_serial_number;
    ELSE
      -- Unscheduled multiple serial entries are not allowed
      -- at this time
      x_return_code := 1;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_code := -1;

END mark_serial;


PROCEDURE remove_serial
  (p_organization_id         IN          NUMBER            ,
   p_subinventory            IN          VARCHAR2          ,
   p_locator_id              IN          NUMBER   := NULL  ,
   p_inventory_item_id       IN          NUMBER            ,
   p_revision                IN          VARCHAR2 := NULL  ,
   p_lot_number              IN          VARCHAR2 := NULL  ,
   p_serial_number           IN          VARCHAR2          ,
   p_parent_lpn_id           IN          NUMBER   := NULL  ,
   p_cycle_count_header_id   IN          NUMBER            ,
   x_return_code             OUT  NOCOPY NUMBER)
IS
l_exist_temp                 NUMBER;
l_group_mark_id              NUMBER;
l_cycle_count_entry_id       NUMBER;

BEGIN
   -- Initialize the return code
   x_return_code := 0;

   -- First check if the multiple serial entry exists
   SELECT COUNT(*)
     INTO l_exist_temp
     FROM DUAL
     WHERE EXISTS
     (SELECT 'multiple-serial'
      FROM mtl_serial_numbers
      WHERE inventory_item_id = p_inventory_item_id
      AND current_organization_id = p_organization_id
      AND serial_number IN
      (SELECT UNIQUE msn.serial_number
       FROM mtl_serial_numbers msn, mtl_cc_serial_numbers mcsn,
       mtl_material_statuses_vl mms, mtl_cycle_count_entries mcce
       WHERE msn.inventory_item_id = p_inventory_item_id
       AND msn.current_organization_id = p_organization_id
       AND msn.current_status IN (1, 3)
       AND msn.status_id = mms.status_id(+)
       AND msn.serial_number = p_serial_number
       AND NVL(msn.lot_number, '###' ) = NVL(p_lot_number, '###')
       AND msn.serial_number = mcsn.serial_number
       AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
       AND mcce.cycle_count_header_id = p_cycle_count_header_id
       AND mcce.inventory_item_id = p_inventory_item_id
       AND mcce.organization_id = p_organization_id
       AND mcce.subinventory = p_subinventory
       AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
       AND NVL(mcce.revision, '@@@@@') = NVL(p_revision, '@@@@@')
       AND NVL(mcce.lot_number, '###' ) = NVL(p_lot_number, '###')
       AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
       AND mcce.entry_status_code IN (1, 3)
       AND NVL(mcce.export_flag, 2) = 2));

   IF (l_exist_temp <> 0) THEN
      -- The serial number entry exists so unmark that serial number
      UPDATE mtl_serial_numbers
	SET group_mark_id = -1
	WHERE inventory_item_id = p_inventory_item_id
	AND current_organization_id = p_organization_id
	AND serial_number = p_serial_number;
    ELSE
      -- The serial number entry does not exist
      x_return_code := 1;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_code := -1;

END remove_serial;


PROCEDURE mark_all_present
  (p_organization_id         IN    NUMBER            ,
   p_subinventory            IN    VARCHAR2          ,
   p_locator_id              IN    NUMBER   := NULL  ,
   p_inventory_item_id       IN    NUMBER            ,
   p_revision                IN    VARCHAR2 := NULL  ,
   p_lot_number              IN    VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN    NUMBER            ,
   p_parent_lpn_id           IN    NUMBER   := NULL)
IS

BEGIN
   -- Multiple serial that are scheduled
   UPDATE mtl_serial_numbers
     SET group_mark_id = 1
     WHERE inventory_item_id = p_inventory_item_id
     AND current_organization_id = p_organization_id
     AND serial_number IN
     (SELECT UNIQUE msn.serial_number
      FROM mtl_serial_numbers msn, mtl_cc_serial_numbers mcsn,
      mtl_material_statuses_vl mms, mtl_cycle_count_entries mcce
      WHERE msn.inventory_item_id = p_inventory_item_id
      AND msn.current_organization_id = p_organization_id
      AND msn.current_status IN (1, 3)
      AND msn.status_id = mms.status_id(+)
      AND NVL(msn.lot_number, '###' ) = NVL(p_lot_number, '###')
      AND msn.serial_number = mcsn.serial_number
      AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
      AND mcce.cycle_count_header_id = p_cycle_count_header_id
      AND mcce.inventory_item_id = p_inventory_item_id
      AND mcce.organization_id = p_organization_id
      AND mcce.subinventory = p_subinventory
      AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
      AND NVL(mcce.revision, '@@@@@') = NVL(p_revision, '@@@@@')
      AND NVL(mcce.lot_number, '###' ) = NVL(p_lot_number, '###')
      AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
      AND mcce.entry_status_code IN (1, 3)
      AND NVL(mcce.export_flag, 2) = 2);

END mark_all_present;


PROCEDURE get_serial_entry_number
  (p_organization_id         IN          NUMBER            ,
   p_subinventory            IN          VARCHAR2          ,
   p_locator_id              IN          NUMBER   := NULL  ,
   p_inventory_item_id       IN          NUMBER            ,
   p_revision                IN          VARCHAR2 := NULL  ,
   p_lot_number              IN          VARCHAR2 := NULL  ,
   p_cycle_count_header_id   IN          NUMBER            ,
   p_parent_lpn_id           IN          NUMBER   := NULL  ,
   x_number                  OUT  NOCOPY NUMBER)
IS

BEGIN
   SELECT COUNT(*)
     INTO x_number
     FROM mtl_serial_numbers msn, mtl_cc_serial_numbers mcsn,
     mtl_material_statuses_vl mms, mtl_cycle_count_entries mcce
     WHERE msn.inventory_item_id = p_inventory_item_id
     AND msn.group_mark_id = 1
     AND msn.current_organization_id = p_organization_id
     AND msn.current_status IN (1, 3)
     AND msn.status_id = mms.status_id(+)
     AND msn.serial_number = mcsn.serial_number
     AND mcsn.cycle_count_entry_id = mcce.cycle_count_entry_id
     AND mcce.cycle_count_header_id = p_cycle_count_header_id
     AND mcce.inventory_item_id = p_inventory_item_id
     AND mcce.organization_id = p_organization_id
     AND mcce.subinventory = p_subinventory
     AND NVL(mcce.locator_id, -99999) = NVL(p_locator_id, -99999)
     AND NVL(mcce.revision, '@@@@@') = NVL(p_revision, '@@@@@')
     AND NVL(mcce.lot_number, '###' ) = NVL(p_lot_number, '###')
     AND NVL(mcce.parent_lpn_id, -99999) = NVL(p_parent_lpn_id, -99999)
     AND mcce.entry_status_code IN (1, 3)
     AND NVL(mcce.export_flag, 2) = 2;

END get_serial_entry_number;

FUNCTION exist_Serial_number(p_serial_number IN VARCHAR2 ,p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER)
        RETURN BOOLEAN IS
   l_temp_buf VARCHAR2(10);
BEGIN
        SELECT 'exists'
          INTO l_temp_buf
          FROM mtl_Serial_numbers
         WHERE serial_number = p_serial_number
           AND inventory_item_id = p_inventory_item_id
           AND current_organization_id = p_organization_id;

        --serial number exists...return true
        RETURN TRUE;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN FALSE;

END exist_Serial_number;

/* Bug# 3595723 */
/* Inserts the serial number into mtl_cc_Serial_numbers if its new, else updates the same */
PROCEDURE insert_serial_number
   (p_serial_number           IN   VARCHAR2 ,
    p_cycle_count_header_id   IN   NUMBER,
    p_organization_id         IN   NUMBER            ,
    p_subinventory            IN   VARCHAR2          ,
    p_locator_id              IN   NUMBER   := NULL  ,
    p_inventory_item_id       IN   NUMBER            ,
    p_revision                IN   VARCHAR2 := NULL  ,
    p_lot_number              IN   VARCHAR2 := NULL  ,
    p_parent_lpn_id           IN   NUMBER   := NULL
   ) IS

   l_number_of_counts     NUMBER;
   l_unit_status_current  NUMBER;
   l_unit_status_prior    NUMBER;
   l_unit_status_first    NUMBER;
   l_approval_condition   NUMBER;
   l_pos_adjustment_qty   NUMBER;
   l_neg_adjustment_qty   NUMBER;
   l_cycle_count_entry_id NUMBER;

BEGIN
   print_debug('Call to insert_serial_number');
   print_debug('p_serial_number ' ||  p_serial_number);
   print_debug('p_cycle_count_header_id ' ||  p_cycle_count_header_id);
   print_debug('p_organization_id ' ||  p_organization_id);
   print_debug('p_subinventory ' ||  p_subinventory);
   print_debug('p_locator_id ' ||  p_locator_id);
   print_debug('p_revision ' ||  p_revision);
   print_debug('p_lot_number ' ||  p_lot_number);
   print_debug('p_parent_lpn_id ' ||  p_parent_lpn_id);

   /* Get the cycle count entry id and approval_condition */
   SELECT cycle_count_entry_id, approval_condition
     INTO l_cycle_count_entry_id , l_approval_condition
     FROM mtl_cycle_count_entries
    WHERE cycle_count_header_id =   p_cycle_count_header_id
      AND entry_status_code IN (1,3)
      AND inventory_item_id =       p_inventory_item_id
      AND organization_id =         p_organization_id
      AND subinventory =            p_subinventory
      AND nvl(locator_id,-999) =    nvl(p_locator_id,-999)
      AND nvl(lot_number,-999) =    nvl(p_lot_number,-999)
      AND nvl(revision,-999) =      nvl(p_revision,-999)
      AND nvl(parent_lpn_id,-999) = nvl(p_parent_lpn_id,-999);

   print_debug('cycle_count_entry_id ' ||  l_cycle_count_entry_id);

   /* Check if the serial number already exists */
   SELECT number_of_counts, unit_status_current, unit_status_first
     INTO l_number_of_counts, l_unit_status_prior, l_unit_status_first
     FROM mtl_cc_serial_numbers
    WHERE cycle_count_entry_id =  l_cycle_count_entry_id
      AND serial_number = p_serial_number;

   print_debug('serial number ' || p_serial_number || ' already exists in mtl_cc_serial_numbers');
   print_debug('l_number_of_counts ' ||  l_number_of_counts);
   print_debug('l_unit_status_prior ' ||  l_unit_status_prior);
   print_debug('l_unit_status_first ' ||  l_unit_status_first);

   /* The serial number exists. Update the data */
   l_unit_status_current := 1; -- 1 -> Present in the count location, 2 -> Absent
   l_pos_adjustment_qty  := 0; -- 1 -> New serial number found at the location
   l_neg_adjustment_qty  := 0; -- 1 -> Serial number not found at the location

   UPDATE MTL_CC_SERIAL_NUMBERS
   SET
      last_update_date                =     SYSDATE,
      last_updated_by                 =     fnd_global.user_id,
      last_update_login               =     fnd_global.login_id,
      number_of_counts                =     nvl(l_number_of_counts,0) + 1,
      unit_status_current             =     l_unit_status_current,
      unit_status_prior               =     l_unit_status_prior,
      unit_status_first               =     l_unit_status_first,
      approval_condition              =     l_approval_condition,
      pos_adjustment_qty              =     l_pos_adjustment_qty,
      neg_adjustment_qty              =     l_neg_adjustment_qty
   WHERE cycle_count_entry_id = l_cycle_count_entry_id
     AND serial_number = p_serial_number;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      /* Serial number does not exist. Insert the serial number */
      l_number_of_counts     := NULL;
      l_unit_status_current  := NULL;
      l_unit_status_prior    := NULL;
      l_unit_status_first    := NULL;
      l_pos_adjustment_qty   := 1;
      l_neg_adjustment_qty   := NULL;

      print_debug('could not find serial number ' || p_serial_number);

      INSERT INTO MTL_CC_SERIAL_NUMBERS(
              cycle_count_entry_id,
              serial_number,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              number_of_counts,
              unit_status_current,
              unit_status_prior,
              unit_status_first,
              approval_condition,
              pos_adjustment_qty,
              neg_adjustment_qty
             ) VALUES (
              l_cycle_count_entry_id,
              p_serial_number,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.LOGIN_ID,
              l_number_of_counts,
              l_unit_status_current,
              l_unit_status_prior,
              l_unit_status_first,
              l_approval_condition,
              l_pos_adjustment_qty,
              l_neg_adjustment_qty
             );

      IF(exist_Serial_number(p_serial_number,p_inventory_item_id,p_organization_id) = FALSE) THEN
         print_Debug('Serial number doesnt exist in msn ');
         --Insert into MSN in case the serial number doesn't exist there.
         INSERT INTO MTL_SERIAL_NUMBERS (
		         inventory_item_id,
		         serial_number,
		         last_update_date,
		         last_updated_by,
		         creation_date,
		         created_by,
		         last_update_login,
		         initialization_date,
		         current_status,
		         revision,
		         lot_number,
		         current_subinventory_code,
		         current_locator_id,
		         current_organization_id,
		         last_txn_source_type_id,
		         last_receipt_issue_type,
		         last_txn_source_id,
               gen_object_id
		        ) VALUES (
		         p_inventory_item_id,
		         p_serial_number,
		         SYSDATE,
		         FND_GLOBAL.USER_ID,
		         SYSDATE,
		         FND_GLOBAL.USER_ID,
		         FND_GLOBAL.LOGIN_ID,
		         SYSDATE,
		         1,
		         p_revision,
		         p_lot_number,
		         p_subinventory,
		         p_locator_id,
		         p_organization_id,
		         9,
		         4,
		         l_cycle_count_entry_id,
                mtl_gen_object_id_s.NEXTVAL);
      END IF;
   WHEN OTHERS THEN
      print_debug('other exceptions');
      NULL;
END insert_Serial_number;

/*Bug # 3646068
  Remove the serial numbers from mtl_cc_Serial_numbers and unmark the serials in mtl_serial_numbers
  for serials that have been entered till now */
PROCEDURE remove_serial_number
(p_cycle_count_header_id   IN   NUMBER,
 p_organization_id         IN   NUMBER            ,
 p_subinventory            IN   VARCHAR2          ,
 p_locator_id              IN   NUMBER   := NULL  ,
 p_inventory_item_id       IN   NUMBER            ,
 p_revision                IN   VARCHAR2 := NULL  ,
 p_lot_number              IN   VARCHAR2 := NULL  ,
 p_parent_lpn_id           IN   NUMBER   := NULL
) IS
   l_cycle_count_entry_id NUMBER;
   l_serial_number VARCHAR2(30);
   l_pos_adjustment_qty NUMBER;

   CURSOR serial_cur IS
      SELECT serial_number,
             pos_adjustment_qty
        FROM mtl_cc_Serial_numbers
       WHERE cycle_count_entry_id = l_cycle_count_entry_id;

BEGIN

  /* Get the cycle count entry id */
   SELECT cycle_count_entry_id
     INTO l_cycle_count_entry_id
     FROM mtl_cycle_count_entries
    WHERE cycle_count_header_id =   p_cycle_count_header_id
      AND entry_status_code IN (1,3)
      AND inventory_item_id =       p_inventory_item_id
      AND organization_id =         p_organization_id
      AND subinventory =            p_subinventory
      AND nvl(locator_id,-999) =    nvl(p_locator_id,-999)
      AND nvl(lot_number,-999) =    nvl(p_lot_number,-999)
      AND nvl(revision,-999) =      nvl(p_revision,-999)
      AND nvl(parent_lpn_id,-999) = nvl(p_parent_lpn_id,-999);

   OPEN serial_cur;
   LOOP
      FETCH serial_cur INTO l_serial_number, l_pos_adjustment_qty;
      EXIT WHEN serial_cur%NOTFOUND;
      IF(nvl(l_pos_adjustment_qty,0) = 1) THEN
         --This was inserted as part of call to insert_serial_number, Delete from mtl_cc_Serial_numbers
         BEGIN
            DELETE FROM mtl_cc_serial_numbers
               WHERE cycle_count_entry_id = l_cycle_count_entry_id
                 AND serial_number = l_serial_number;
         EXCEPTION
            WHEN OTHERS THEN
               print_debug('Exception while trying to delete from mtl_cc_serial_numbers for serial ' || l_serial_number);
         END;
      END IF;

      --Unmark the serial number in mtl_Serial_numbers
      BEGIN

         UPDATE mtl_serial_numbers
            SET group_mark_id = NULL
          WHERE serial_number = l_serial_number
            AND inventory_item_id = p_inventory_item_id
            AND current_organization_id = p_organization_id;
      EXCEPTION
         WHEN OTHERS THEN
            print_debug('Exception while updating MSN for serial ' || l_serial_number);
      END;
   END LOOP;
END remove_Serial_number;



END INV_CYC_SERIALS;

/

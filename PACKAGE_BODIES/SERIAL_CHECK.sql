--------------------------------------------------------
--  DDL for Package Body SERIAL_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SERIAL_CHECK" AS
/* $Header: INVMKUMB.pls 120.5 2006/05/13 05:17:04 ramarava noship $ */

  g_debug NUMBER;

PROCEDURE inv_mark_serial
  ( from_serial_number  VARCHAR2,
    to_serial_number    VARCHAR2 DEFAULT NULL,
    item_id             NUMBER,
    org_id              NUMBER,
    hdr_id              NUMBER,
    temp_id             NUMBER,
    lot_temp_id         NUMBER,
    success             IN OUT  NOCOPY NUMBER)
IS
    l_debug NUMBER := 0;
    l_success NUMBER;
BEGIN

    /*** {{ R12 Enhanced reservations code changes ***/
    -- call the overloaded inv_mark_serial API, with null reservation_id
    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
       inv_log_util.trace('In inv_mark_serial, no reservation', 'SERIAL_CHECK');
    END IF;

    inv_mark_rsv_serial
      (  from_serial_number => from_serial_number
       , to_serial_number   => to_serial_number
       , item_id            => item_id
       , org_id             => org_id
       , hdr_id             => hdr_id
       , temp_id            => temp_id
       , lot_temp_id        => lot_temp_id
       , p_reservation_id   => null
       , p_update_reservation => fnd_api.g_false
       , success              => l_success
      );

     IF (l_debug = 1) THEN
         inv_log_util.trace('success is ' || l_success, 'SERIAL_CHECK');
     END IF;

     success := l_success;
     /*** End R12 }} ***/

EXCEPTION
   WHEN OTHERS then
         if( l_debug = 1 ) then
            inv_log_util.trace('success is ' || success, 'SERIAL_CHECK');
            inv_log_util.trace('sqlerrm is ' || substr(sqlerrm, 1, 200), 'SERIAL_CHECK');
         end if;
      success := -3;
END inv_mark_serial;


/*** {{ R12 Enhanced reservations code changes ***/
-- overloaded procedure inv_mark_serial to take input of reservation_id
PROCEDURE inv_mark_rsv_serial
  ( from_serial_number	 VARCHAR2,
    to_serial_number	 VARCHAR2 DEFAULT NULL,
    item_id		 NUMBER,
    org_id		 NUMBER,
    hdr_id		 NUMBER,
    temp_id		 NUMBER,
    lot_temp_id		 NUMBER,
    p_reservation_id     NUMBER DEFAULT NULL,  /*** {{ R12 Enhanced reservations code changes }} ***/
    p_update_reservation VARCHAR2 DEFAULT fnd_api.g_true, /*** {{ R12 Enhanced reservations code changes }} ***/
    success		 IN OUT	NOCOPY NUMBER)
IS
   l_debug NUMBER := 0;
   /*** {{ R12 Enhanced reservations code changes ***/
   l_return_status      VARCHAR2(1)   := fnd_api.g_ret_sts_success;
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);
   /*** End R12 }} ***/
BEGIN
   IF (g_debug IS NULL) THEN
       g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   END IF;

   l_debug := g_debug;

   IF (l_debug = 1) THEN
      inv_log_util.trace('In inv_mark_serial overloaded with reservation_id', 'SERIAL_CHECK');
   END IF;

   DECLARE
      marked_numbers_found          NUMBER:= 0;
      l_update_count                NUMBER:= 0;  /*** {{ R12 Enhanced reservations code changes ***/
      l_hdr_id                      NUMBER;
      CURSOR serial_lock1 IS
	 SELECT group_mark_id
	   FROM mtl_serial_numbers
	   WHERE current_organization_id = org_id
	   AND inventory_item_id = item_id
	   AND serial_number BETWEEN from_serial_number
	   AND to_serial_number
	   AND LENGTH(serial_number) = Length(from_serial_number)
	   FOR UPDATE OF group_mark_id NOWAIT;

      CURSOR serial_lock2 IS
	 SELECT group_mark_id
	   FROM mtl_serial_numbers
	   WHERE current_organization_id = org_id
	   AND inventory_item_id = item_id
	   AND serial_number = from_serial_number
	   FOR UPDATE OF group_mark_id NOWAIT;

   BEGIN

      SAVEPOINT mark_procedure_scope;
      IF hdr_id IS NULL then
	 l_hdr_id := 99999;
       else
	 l_hdr_id := hdr_id;
      end if;
      success := 1;

      if( l_debug = 1 ) then
	inv_log_util.trace('Inside inv_mark_serial hdr_id is ' || l_hdr_id, 'SERIAL_CHECK');
      end if;
      IF (to_serial_number IS NOT NULL)  and  NOT (from_serial_number = to_serial_number ) then
	 if( l_debug = 1 ) then
	     inv_log_util.trace('to_serial_number is ' || to_serial_number, 'SERIAL_CHECK');
	 end if;
	 success := 1 ;
	 OPEN serial_lock1 ;

	 SELECT COUNT(group_mark_id)
	   INTO marked_numbers_found
	   FROM mtl_serial_numbers
	   WHERE inventory_item_id = item_id
	   AND group_mark_id > 0
	   AND serial_number between from_serial_number
	   AND to_serial_number
	   AND LENGTH(serial_number) = LENGTH(from_serial_number) ;
	   --BUG 2249383 Cannot have same item with serial number in different org
	   --AND current_organization_id = org_id

	 if( l_debug = 1 ) then
	     inv_log_util.trace('marked_numbers_found is ' || marked_numbers_found, 'SERIAL_CHECK');
	 end if;
	 IF (marked_numbers_found > 0) then
	    success := -1 ;
	    CLOSE serial_lock1 ;
	    ROLLBACK TO mark_procedure_scope ;
	  else

	    /* Bug 2357069 --
	    -- Delete the condition of current_organization_id = org_id
	    -- Here is the scenario why we should not consider the current_organization_id = org_id in the
            -- where clause.
            --  Item    Current Organization Serial_Status		 Serial Number   Serial Type
            --  ABC        M1                4 (Issued from Stores)      S1 to S10       Unique in Org
            --  ABC        M2                                                            Unique within Item
            -- Since Serial Number S1 to S10 has status 4 (issued from Stores), user should be able
            -- to chose S1 to S10 for receipt transaction to organization M2, even though the current
            -- organization of serial S1 to S10 is M1.
	    */
	    UPDATE mtl_serial_numbers
	      SET lot_line_mark_id = lot_temp_id,
	      line_mark_id = temp_id,
	      group_mark_id = l_hdr_id,
              reservation_id = nvl(p_reservation_id, reservation_id) /*** {{ R12 Enhanced reservations code changes ***/
	      WHERE inventory_item_id = item_id
	      AND serial_number between from_serial_number
	      AND to_serial_number
	      AND LENGTH(serial_number) = LENGTH(from_serial_number) ;
            l_update_count := SQL%ROWCOUNT;   /*** {{ R12 Enhanced reservations code changes ***/
	    CLOSE serial_lock1;
	    success := 3;
	 end if;
	 if( l_debug = 1 ) then
	    inv_log_util.trace('success is ' || success, 'SERIAL_CHECK');
	 end if;
       else
	 if( l_debug = 1) then
	     inv_log_util.trace('to_serial_number is null or same', 'SERIAL_CHECK');
	 end if;
	 success := 2 ;
	 OPEN serial_lock2 ;

	 SELECT COUNT(group_mark_id)
	   INTO marked_numbers_found
	   FROM mtl_serial_numbers
	   WHERE inventory_item_id = item_id
	   AND group_mark_id > 0
	   AND serial_number = from_serial_number ;
	   --BUG 2249383 Cannot have same item with serial number in different org
	   --AND current_organization_id = org_id

	 if( l_debug = 1 ) then
	     inv_log_util.trace('marked_numbers_found is ' || marked_numbers_found, 'SERIAL_CHECK');
	 end if;
	 IF (marked_numbers_found > 0) then
	    success := -1;
	    CLOSE serial_lock2;
	    ROLLBACK TO mark_procedure_scope;
	  else
	    /* Bug 2357069 --
	    -- Delete the condition of current_organization_id = org_id
	    -- Here is the scenario why we should not consider the current_organization_id = org_id in the
            -- where clause.
            --  Item    Current Organization Serial_Status		 Serial Number   Serial Type
            --  ABC        M1                4 (Issued from Stores)      S1 to S10       Unique in Org
            --  ABC        M2                                                            Unique within Item
            -- Since Serial Number S1 to S10 has status 4 (issued from Stores), user should be able
            -- to chose S1 to S10 for receipt transaction to organization M2, even though the current
            -- organization of serial S1 to S10 is M1.
	    */

	    UPDATE mtl_serial_numbers
	      SET lot_line_mark_id = lot_temp_id,
	      line_mark_id = temp_id,
	      group_mark_id = l_hdr_id,
              reservation_id = nvl(p_reservation_id, reservation_id)   /*** {{ R12 Enhanced reservations code changes ***/
	      WHERE inventory_item_id = item_id
	      AND serial_number = from_serial_number ;
            l_update_count := 1;   /*** {{ R12 Enhanced reservations code changes ***/
	    CLOSE serial_lock2;
	    success := 3;
	 end if;
	 if( l_debug = 1 ) then
	    inv_log_util.trace('success is ' || success, 'SERIAL_CHECK');
	 end if;
      end if;

      /*** {{ R12 Enhanced reservations code changes ***/
      IF (p_update_reservation = fnd_api.g_true and p_reservation_id is not null) THEN
          BEGIN
             update mtl_reservations
             set    serial_reservation_quantity = serial_reservation_quantity + l_update_count
             where  reservation_id = p_reservation_id;

          EXCEPTION
             WHEN others THEN
               IF (l_debug = 1) THEN
                  inv_log_util.trace('Error updating serial_reservation_quantity in mtl_reservations', 'INV_MARK_SERIAL');
                  inv_log_util.trace('sqlerrm is ' || substr(sqlerrm, 1, 200), 'INV_MARK_SERIAL');
               END IF;
          END;
      END IF;
      /*** End R12 }} ***/
   EXCEPTION
      WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION then
	 IF success = 1 then
	    CLOSE serial_lock1;
	  else
	    CLOSE serial_lock2;
	 end if;
	 success := -2;
	 if( l_debug = 1 ) then
	    inv_log_util.trace('success is ' || success, 'SERIAL_CHECK');
	    inv_log_util.trace('app_exceptions.record_lock_exception', 'SERIAL_CHECK');
	 end if;
      WHEN OTHERS then
	 IF success = 1 then
	CLOSE serial_lock1;
	  else
	    CLOSE serial_lock2;
	 end if;
	 success := -3;
	 if( l_debug = 1 ) then
	    inv_log_util.trace('success is ' || success, 'SERIAL_CHECK');
	    inv_log_util.trace('sqlerrm is ' || substr(sqlerrm, 1, 200), 'SERIAL_CHECK');
	 end if;
   END;
   null;
EXCEPTION
   WHEN OTHERS then
	 if( l_debug = 1 ) then
	    inv_log_util.trace('success is ' || success, 'SERIAL_CHECK');
	    inv_log_util.trace('sqlerrm is ' || substr(sqlerrm, 1, 200), 'SERIAL_CHECK');
	 end if;
      success := -3;
END inv_mark_rsv_serial;

PROCEDURE inv_unmark_serial
  ( from_serial_number   IN  VARCHAR2,
    to_serial_number     IN  VARCHAR2,
    serial_code          IN  NUMBER,
    hdr_id               IN  NUMBER,
    temp_id              IN  NUMBER DEFAULT NULL,
    lot_temp_id          IN  NUMBER DEFAULT NULL,
    p_inventory_item_id  IN  NUMBER DEFAULT NULL)
IS
    l_debug NUMBER := 0;
    l_success NUMBER;
BEGIN

    /*** {{ R12 Enhanced reservations code changes ***/
    -- call the overloaded inv_unmark_rsv_serial API, with null reservation_id
    IF (g_debug IS NULL) THEN
        g_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    END IF;

    l_debug := g_debug;

    IF (l_debug = 1) THEN
       inv_log_util.trace('In inv_unmark_serial, no reservation', 'SERIAL_CHECK');
    END IF;

    inv_unmark_rsv_serial
      (  from_serial_number   => from_serial_number
       , to_serial_number     => to_serial_number
       , serial_code          => serial_code
       , hdr_id               => hdr_id
       , temp_id              => temp_id
       , lot_temp_id          => lot_temp_id
       , p_inventory_item_id  => p_inventory_item_id
       , p_update_reservation => fnd_api.g_false
      );

    /*** End R12 }} ***/

EXCEPTION
   WHEN OTHERS then
      if( l_debug = 1 ) then
        inv_log_util.trace('exception in inv_unmark_serial, sqlerrm is ' || substr(sqlerrm, 1, 200), 'SERIAL_CHECK');
      end if;
END inv_unmark_serial;


  PROCEDURE inv_unmark_rsv_serial(
  		  from_serial_number          IN       VARCHAR2
  		, to_serial_number            IN       VARCHAR2
  		, serial_code                 IN       NUMBER
  		, hdr_id                      IN       NUMBER
  		, temp_id                     IN       NUMBER DEFAULT NULL
  		, lot_temp_id                 IN       NUMBER DEFAULT NULL
  		, p_inventory_item_id         IN       NUMBER DEFAULT NULL
  		, p_update_reservation        IN       VARCHAR2 DEFAULT fnd_api.g_true
  		) IS   /*** {{ R12 Enhanced reservations code changes ***/
    unmarked_value                NUMBER := -1;
    l_debug                       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    /*** {{ R12 Enhanced reservations code changes ***/
    l_return_status               VARCHAR2(1) := fnd_api.g_ret_sts_success;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);

    TYPE rsv_table IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    TYPE rsv_count_table IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

    l_rsv_id_tbl                  rsv_table;
    l_rsv_count_tbl               rsv_count_table;
    l_update_count                NUMBER;

    CURSOR serial_rsv1 IS
      SELECT reservation_id
           , COUNT(reservation_id)
        FROM mtl_serial_numbers
       WHERE serial_number = from_serial_number AND
             inventory_item_id = p_inventory_item_id AND
             reservation_id IS NOT NULL
      GROUP BY reservation_id;

    CURSOR serial_rsv2 IS
      SELECT   reservation_id
             , COUNT(reservation_id)
          FROM mtl_serial_numbers
         WHERE serial_number >= NVL(from_serial_number, serial_number) AND
               serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
               inventory_item_id = p_inventory_item_id AND
               reservation_id IS NOT NULL
      GROUP BY reservation_id;

    CURSOR serial_rsv3 IS
      SELECT   reservation_id
             , COUNT(reservation_id)
          FROM mtl_serial_numbers
         WHERE group_mark_id IN(hdr_id, lot_temp_id, temp_id) AND
               (
                line_mark_id = temp_id OR
                line_mark_id IS NULL OR
                line_mark_id = -1
               ) AND
               (
                lot_line_mark_id = lot_temp_id OR
                lot_line_mark_id IS NULL
                OR lot_line_mark_id = -1
               ) AND
               serial_number >= NVL(from_serial_number, serial_number) AND
               serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
               LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) ) AND
               reservation_id IS NOT NULL
      GROUP BY reservation_id;

    CURSOR serial_rsv4 IS
      SELECT   reservation_id
             , COUNT(reservation_id)
          FROM mtl_serial_numbers
         WHERE group_mark_id IN(hdr_id, temp_id) AND
               (
                line_mark_id = temp_id OR
                line_mark_id IS NULL OR
                line_mark_id = -1
               ) AND
               serial_number >= NVL(from_serial_number, serial_number) AND
               serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
               LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) ) AND
               reservation_id IS NOT NULL
      GROUP BY reservation_id;

    CURSOR serial_rsv5 IS
      SELECT   reservation_id
             , COUNT(reservation_id)
          FROM mtl_serial_numbers
         WHERE group_mark_id = hdr_id AND
               serial_number >= NVL(from_serial_number, serial_number) AND
               serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
               LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) ) AND
               reservation_id IS NOT NULL
      GROUP BY reservation_id;
  /*** End R12 }} ***/
  BEGIN
    -- Need to delete from table only if serial_control_code allowed dynamic
    -- entries in the first place. If dynamic entries not allowed, we need
    -- not do this delete statement, but only the update. We will always have
    -- hdr_id and temp_id.

    --  if (serial_code = 5 OR serial_code = 6) then
    -- unmarked_value := -1 ;
    -- end if;
    IF (l_debug = 1) THEN
      inv_log_util.TRACE('Inside inv_unmark_serial', 'SERIAL_CHECK');
      inv_log_util.TRACE('from_serial_number = ' || from_serial_number
          || ' to_serial_number = ' || to_serial_number, 'SERIAL_CHECK');
      inv_log_util.TRACE('serial_code = ' || serial_code || ' hdr_id = ' || hdr_id
          || ' temp_id = ' || temp_id || ' lot_temp_id = ' || lot_temp_id
          || ' p_inventory_item_id = ' || p_inventory_item_id
          || ' p_update_reservation = ' || p_update_reservation , 'SERIAL_CHECK');
    END IF;

    IF (p_inventory_item_id IS NOT NULL AND hdr_id IS NULL AND temp_id IS NULL AND
        lot_temp_id IS NULL) THEN
      IF (
          ( (from_serial_number IS NOT NULL) AND(to_serial_number IS NULL) ) OR
          (
           from_serial_number = to_serial_number
          )
         ) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Update msn with serial_number= from_serial_number and '
            || 'inventory_item_id = ' || p_inventory_item_id, 'SERIAL_CHECK');
        END IF;

        /*** {{ R12 Enhanced reservations code changes ***/
        IF (p_update_reservation = fnd_api.g_true) THEN
          OPEN serial_rsv1;

          FETCH serial_rsv1
          BULK COLLECT
          INTO l_rsv_id_tbl
             , l_rsv_count_tbl;
          CLOSE serial_rsv1;
        END IF;
        /*** End R12 }} ***/

        IF (p_update_reservation = fnd_api.g_true) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Case 1 and p_update_reservation is T', 'inv_unmark_rsv_serial');
          END IF;
          UPDATE mtl_serial_numbers
            SET line_mark_id = unmarked_value
             , group_mark_id = unmarked_value
             , lot_line_mark_id = unmarked_value
             , reservation_id = NULL   /*** {{ R12 Enhanced reservations code changes ***/
            WHERE serial_number = from_serial_number AND inventory_item_id = p_inventory_item_id;
          IF (l_debug = 1) THEN
            inv_log_util.trace('Case 1, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Case 1 and p_update_reservation it F', 'inv_unmark_rsv_serial');
          END IF;
          UPDATE mtl_serial_numbers
            SET line_mark_id = unmarked_value
             , group_mark_id = unmarked_value
             , lot_line_mark_id = unmarked_value
            WHERE serial_number = from_serial_number AND inventory_item_id = p_inventory_item_id;
          IF (l_debug = 1) THEN
            inv_log_util.trace('Case 1, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
          END IF;
        END IF;
      ELSE
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Update msn with serial_number >=  '
            || ' nvl(from_serial_number, serial_number) '
            || ' AND serial_number <=  nvl(to_serial_number, '
            || 'nvl(from_serial_number, serial_number)) AND inventory_item_id= '
            || p_inventory_item_id, 'SERIAL_CHECK');
        END IF;

        /*** {{ R12 Enhanced reservations code changes ***/
        IF (p_update_reservation = fnd_api.g_true) THEN
          OPEN serial_rsv2;
          FETCH serial_rsv2
          BULK COLLECT
          INTO l_rsv_id_tbl
             , l_rsv_count_tbl;
          CLOSE serial_rsv2;
        END IF;
        /*** End R12 }} ***/

        IF (p_update_reservation = fnd_api.g_true) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Case 2 and p_update_reservation it T', 'inv_unmark_rsv_serial');
          END IF;
          UPDATE mtl_serial_numbers
            SET line_mark_id = unmarked_value
             , group_mark_id = unmarked_value
             , lot_line_mark_id = unmarked_value
             , reservation_id = NULL   /*** {{ R12 Enhanced reservations code changes ***/
            WHERE serial_number >= NVL(from_serial_number, serial_number) AND
               serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
               inventory_item_id = p_inventory_item_id;
          IF (l_debug = 1) THEN
            inv_log_util.trace('Case 2, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Case 2 and p_update_reservation it F', 'inv_unmark_rsv_serial');
          END IF;
          UPDATE mtl_serial_numbers
            SET line_mark_id = unmarked_value
             , group_mark_id = unmarked_value
             , lot_line_mark_id = unmarked_value
            WHERE serial_number >= NVL(from_serial_number, serial_number) AND
               serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
               inventory_item_id = p_inventory_item_id;
          IF (l_debug = 1) THEN
            inv_log_util.trace('Case 2, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
          END IF;
        END IF;   --END IF p_update_reservation is T
      END IF;   --END IF fm_serial = to_serial
    ELSE
      IF (lot_temp_id IS NOT NULL) THEN
        IF (l_debug = 1) THEN
          inv_log_util.TRACE('Update msn with group_mark_id in ('
            || hdr_id || ', ' || lot_temp_id || ', ' || temp_id
            || 'AND (line_mark_id = ' || temp_id
            || ' OR line_mark_id is NULL OR line_mark_id = -1)', 'SERIAL_CHECK');
          inv_log_util.TRACE(' AND (lot_line_mark_id = '|| lot_temp_id
            || ' OR lot_line_mark_id IS NULL OR '
            || 'lot_line_mark_id = -1) AND serial_number >= nvl(from_serial_number, serial_number) '
            || ' serial_number <=  nvl(to_serial_number, nvl(from_serial_number, serial_number)) '
            || ' AND length(serial_number) =  length(nvl(from_serial_number, serial_number)) ', 'SERIAL_CHECK');
        END IF;

        /*** {{ R12 Enhanced reservations code changes ***/
        IF (p_update_reservation = fnd_api.g_true) THEN
          OPEN serial_rsv3;
          FETCH serial_rsv3
          BULK COLLECT
          INTO l_rsv_id_tbl
             , l_rsv_count_tbl;
          CLOSE serial_rsv3;
        END IF;
        /*** End R12 }} ***/

        IF (p_update_reservation = fnd_api.g_true) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Case 3 and p_update_reservation it T', 'inv_unmark_rsv_serial');
          END IF;
          UPDATE mtl_serial_numbers
           SET line_mark_id = unmarked_value
             , group_mark_id = unmarked_value
             , lot_line_mark_id = unmarked_value
             , reservation_id = NULL   /*** {{ R12 Enhanced reservations code changes ***/
            WHERE group_mark_id IN(hdr_id, lot_temp_id, temp_id)   -- Bug 2491094: Added Temp ID also
            AND
               (
                line_mark_id = temp_id OR line_mark_id IS NULL OR line_mark_id = -1
               ) AND
               (
                lot_line_mark_id = lot_temp_id OR lot_line_mark_id IS NULL OR lot_line_mark_id = -1
               ) AND
               serial_number >= NVL(from_serial_number, serial_number) AND
               serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
               LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) );
          IF (l_debug = 1) THEN
            inv_log_util.trace('Case 3, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('Case 3 and p_update_reservation it F', 'inv_unmark_rsv_serial');
          END IF;
          UPDATE mtl_serial_numbers
           SET line_mark_id = unmarked_value
             , group_mark_id = unmarked_value
             , lot_line_mark_id = unmarked_value
            WHERE group_mark_id IN(hdr_id, lot_temp_id, temp_id) -- Bug 2491094: Added Temp ID also
            AND
               (
                line_mark_id = temp_id OR line_mark_id IS NULL OR line_mark_id = -1
               ) AND
               (
                lot_line_mark_id = lot_temp_id OR lot_line_mark_id IS NULL OR lot_line_mark_id = -1
               ) AND
               serial_number >= NVL(from_serial_number, serial_number) AND
               serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
               LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) );
          IF (l_debug = 1) THEN
            inv_log_util.trace('Case 3, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
          END IF;
        END IF;
      ELSE
        IF (temp_id IS NOT NULL) THEN
          IF (l_debug = 1) THEN
            inv_log_util.TRACE(
                 'update msn with group_mark_id in ('|| hdr_id || ', '|| temp_id
              || ' AND (line_mark_id = '|| temp_id || ' OR line_mark_id is NULL or line_mark_id = -1 ) AND '
              || ' serial_number >= nvl(from_serial_number, serial_number) '
              || ' AND serial_number <=  nvl(to_serial_number, nvl(from_serial_number, serial_number)) '
              || ' AND length(serial_number) = length(nvl(from_serial_number, serial_number))', 'SERIAL_CHECK');
          END IF;

          /*** {{ R12 Enhanced reservations code changes ***/
          IF (p_update_reservation = fnd_api.g_true) THEN
            OPEN serial_rsv4;
            FETCH serial_rsv4
            BULK COLLECT
            INTO l_rsv_id_tbl
               , l_rsv_count_tbl;
            CLOSE serial_rsv4;
          END IF;
          /*** End R12 }} ***/

          IF (p_update_reservation = fnd_api.g_true) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Case 4 and p_update_reservation it T', 'inv_unmark_rsv_serial');
            END IF;
            UPDATE mtl_serial_numbers
            SET line_mark_id = unmarked_value
               , group_mark_id = unmarked_value
               , lot_line_mark_id = unmarked_value
               , reservation_id = NULL   /*** {{ R12 Enhanced reservations code changes ***/
            WHERE group_mark_id IN(hdr_id, temp_id) AND
                 (
                  line_mark_id = temp_id OR line_mark_id IS NULL OR line_mark_id = -1
                 ) AND
                 serial_number >= NVL(from_serial_number, serial_number) AND
                 serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
                 LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) );
            IF (l_debug = 1) THEN
              inv_log_util.trace('Case 4, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Case 4 and p_update_reservation it F', 'inv_unmark_rsv_serial');
            END IF;
            UPDATE mtl_serial_numbers
            SET line_mark_id = unmarked_value
               , group_mark_id = unmarked_value
               , lot_line_mark_id = unmarked_value
            WHERE group_mark_id IN(hdr_id, temp_id) AND
                 (
                  line_mark_id = temp_id OR line_mark_id IS NULL OR line_mark_id = -1
                 ) AND
                 serial_number >= NVL(from_serial_number, serial_number) AND
                 serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
                 LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) );
            IF (l_debug = 1) THEN
              inv_log_util.trace('Case 4, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
            END IF;
          END IF;
        ELSE
          IF (l_debug = 1) THEN
            inv_log_util.TRACE('update msn with group_mark_id = '
              || hdr_id || ' AND serial_number >= nvl(from_serial_number, serial_number) '
              || ' AND serial_number <= nvl(to_serial_number, nvl(from_serial_number, serial_number)) '
              || ' AND length(serial_number) = length(nvl(from_serial_number, serial_number))', 'SERIAL_CHECK');
          END IF;

          /*** {{ R12 Enhanced reservations code changes ***/
          IF (p_update_reservation = fnd_api.g_true) THEN
            OPEN serial_rsv5;
            FETCH serial_rsv5
            BULK COLLECT
            INTO l_rsv_id_tbl
               , l_rsv_count_tbl;
            CLOSE serial_rsv5;
          END IF;
          /*** End R12 }} ***/

          IF (p_update_reservation = fnd_api.g_true) THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Case 5 and p_update_reservation it T', 'inv_unmark_rsv_serial');
            END IF;
            UPDATE mtl_serial_numbers
            SET line_mark_id = unmarked_value
               , group_mark_id = unmarked_value
               , lot_line_mark_id = unmarked_value
               , reservation_id = NULL   /*** {{ R12 Enhanced reservations code changes ***/
            WHERE group_mark_id = hdr_id AND
                 serial_number >= NVL(from_serial_number, serial_number) AND
                 serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
                 LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) );
            IF (l_debug = 1) THEN
              inv_log_util.trace('Case 5, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
            END IF;
          ELSE
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Case 5 and p_update_reservation it F', 'inv_unmark_rsv_serial');
            END IF;
            UPDATE mtl_serial_numbers
            SET line_mark_id = unmarked_value
               , group_mark_id = unmarked_value
               , lot_line_mark_id = unmarked_value
            WHERE group_mark_id = hdr_id AND
                 serial_number >= NVL(from_serial_number, serial_number) AND
                 serial_number <= NVL(to_serial_number, NVL(from_serial_number, serial_number) ) AND
                 LENGTH(serial_number) = LENGTH(NVL(from_serial_number, serial_number) );
            IF (l_debug = 1) THEN
              inv_log_util.trace('Case 5, no. of serials unmarked: ' || SQL%rowcount, 'inv_unmark_rsv_serial');
            END IF;
          END IF;   --END IF p_update_reservation = F
        END IF;   --END IF p_temp_id IS NOT NULL
      END IF;   --END IF lote_temp_id IS NOT NULL
    END IF;   -- inventory_item_id is null

    /*** {{ R12 Enhanced reservations code changes ***/
    IF (p_update_reservation = fnd_api.g_true) THEN
      FOR i IN 1 .. l_rsv_id_tbl.COUNT LOOP
        l_update_count  := l_rsv_count_tbl(i) * -1;
        BEGIN
          UPDATE mtl_reservations
             SET serial_reservation_quantity = serial_reservation_quantity + l_update_count
           WHERE reservation_id = l_rsv_id_tbl(i);
        EXCEPTION
          WHEN OTHERS THEN
            IF (l_debug = 1) THEN
              inv_log_util.TRACE('Error updating serial_reservation_quantity in mtl_reservations', 'INV_UNMARK_SERIAL');
              inv_log_util.TRACE('sqlerrm is ' || SUBSTR(SQLERRM, 1, 200), 'INV_UNMARK_SERIAL');
            END IF;
        END;
      END LOOP;
    END IF;
  /*** End R12 }} ***/
  END inv_unmark_rsv_serial;

PROCEDURE inv_update_marked_serial
  ( from_serial_number IN         VARCHAR2,
    to_serial_number   IN         VARCHAR2 DEFAULT NULL,
    item_id            IN         NUMBER,
    org_id             IN         NUMBER,
    temp_id            IN         NUMBER DEFAULT NULL,
    hdr_id             IN         NUMBER DEFAULT NULL,
    lot_temp_id        IN         NUMBER DEFAULT NULL,
    success            OUT NOCOPY BOOLEAN ) IS

    	l_debug NUMBER :=  NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
	IF (l_debug = 1) THEN
		inv_log_util.trace('Inside inv_update_marked_serial','SERIAL_CHECK');
		inv_log_util.trace('from_serial_number='||from_serial_number,'SERIAL_CHECK');
		inv_log_util.trace('to_serial_number='||to_serial_number,'SERIAL_CHECK');
		inv_log_util.trace('item_id='||item_id,'SERIAL_CHECK');
		inv_log_util.trace('org_id='||org_id,'SERIAL_CHECK');
		inv_log_util.trace('temp_id='||temp_id,'SERIAL_CHECK');
		inv_log_util.trace('hdr_id='||hdr_id,'SERIAL_CHECK');
		inv_log_util.trace('lot_temp_id='||lot_temp_id,'SERIAL_CHECK');
	END IF;

	success := TRUE;

	IF (temp_id IS NULL AND hdr_id IS NULL) THEN
		IF (l_debug = 1) THEN
			inv_log_util.trace('temp_id, hdr_id are both null, return false','SERIAL_CHECK');
		END IF;
		success := FALSE;
		RETURN;
	END IF;

	IF (to_serial_number IS NULL OR (from_serial_number = to_serial_number)) THEN

		IF (l_debug = 1) THEN
			inv_log_util.trace('to_serial_number is null or same as from_serial_number','SERIAL_CHECK');
		END IF;

		BEGIN
			UPDATE mtl_serial_numbers
	        	SET    group_mark_id = nvl(temp_id, hdr_id)
	      		WHERE  inventory_item_id = item_id
			AND    current_organization_id = org_id
	      		AND    serial_number = from_serial_number ;
		EXCEPTION
			WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
      				success := FALSE;
				IF (l_debug = 1) THEN
					inv_log_util.trace('APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION','SERIAL_CHECK');
				END IF;
		END;

		success := TRUE;
	ELSIF (to_serial_number IS NOT NULL AND NOT (from_serial_number = to_serial_number)) THEN

		IF (l_debug = 1) THEN
			inv_log_util.trace('to_serial_number not null and different from from_serial_number','SERIAL_CHECK');
		END IF;

		BEGIN
			UPDATE mtl_serial_numbers
	      		SET    group_mark_id = nvl(temp_id, hdr_id)
	      		WHERE  inventory_item_id = item_id
			AND    current_organization_id = org_id
	      		AND    serial_number between from_serial_number AND to_serial_number
	      		AND    LENGTH(serial_number) = LENGTH(from_serial_number) ;
		EXCEPTION
			WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
      				success := FALSE;
				IF (l_debug = 1) THEN
					inv_log_util.trace('APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION','SERIAL_CHECK');
				END IF;
		END;

		success := TRUE;


	END IF;

EXCEPTION
	WHEN others THEN
      		success := FALSE;
		IF ( l_debug = 1 ) THEN
	    		inv_log_util.trace('sqlerrm is ' || substr(sqlerrm, 1, 200),'SERIAL_CHECK');
	 	END IF;

END inv_update_marked_serial;

END SERIAL_CHECK;

/

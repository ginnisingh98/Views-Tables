--------------------------------------------------------
--  DDL for Package Body GMI_LOCKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_LOCKS" AS
/*  $Header: GMIULCKB.pls 115.9 2004/01/08 21:14:44 adeshmuk ship $  */

/* ========================================================================
*  This file contains the body of a package which
*  locks rows in ic_loct_inv. It is intended to be used by the allocation
*  logic in the OM/OPM integration. At the start of an allocation session
*  for a particular item/whse/lot/location, the procedures in this package
*  prevent users from accessing the inventory simultaneously whilst it is
*  being allocated. This prevents multiple allocation of the same stock and
*  eliminates deadlocks between sessions
*
*  For convenience the lock_inventory procedure is overloaded so the same
*  routine can be called all the time, just by specifying the desired
*  parameter set. Choose from:
*
* 		Item
* 		Item, Warehouse
* 		Item, Warehouse, Lot, Lot Status
* 		Item, Warehouse, Location
* 		Item, Warehouse, Lot, Lot Status, Location
*
*  These versions return a status value as follows:
*
* 		TRUE =>  Inventory rows locked successfully
* 		FALSE => Inventory rows locked by another user, try later
*
*
*  Another variant exists for use in situations where the calling code needs
*  a bit more control over what's happening. The parameter set here is:
*
* 		Item, Warehouse, Lot, Lot Status, Location, Retries
*
*  where the 'retries' parameter is the number of times to attempt
*   the locking (which
*  will take place at 1 second intervals) before giving up.
*  For this version of the procedure the return status can be
*
* 		TRUE =>  Inventory rows locked siccessfully
* 		FALSE => Inventory rows locked by another user, try later
* 		NULL =>  No rows locked because none matched the parameters
*
*  The final (NULL) return could be significant in some situations.
* The other versions
*  of the procedure will return TRUE in this case.
*
*
*
*  All calls to this package must specify an item_id at the very least.
* The other values
*  can be passed as NULL.
*  If a warehouse is passed as NULL, locking could take place across
*  warehouses.
* If lot_id is NULL but lot_status is not, all lots of the item with this
*  status will be locked, possibly across warehouses if that too is NULL.
* The possibilities  are numerous.
*
*
*  HISTORY
*
*  02-Mar-2000	P.J.Schofield, Oracle UK
* 		Package created.
*  28-Oct-2002  J.DiIorio 11.5.1J Bug#2643440 - added nocopy.
*
*  16-Dec-2003  A. Mundhe Bug 3303486
*               Modified the code to remove the usage of NVL to help improve performance.
*
*  07-Jan-2004  A. Mundhe Bug 3356201
*               Added new overloaded lock_inventory proceudre to handle - Item,
*               Warehouse, Lot and location parameter set.
* ============================================================================*/

/*   Global variables   */
G_PKG_NAME      CONSTANT  VARCHAR2(30):='GMI_Locks';

	/*   This procedure is private to the package.  */

	PROCEDURE lock_rows
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_lot_id	IN ic_loct_inv.lot_id%TYPE,
			i_lot_status	IN ic_loct_inv.lot_status%TYPE,
			i_location	IN ic_loct_inv.location%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		)
	IS

		row_count		NUMBER;
		statement		VARCHAR2(1000);
		TYPE ref_cursor_type IS REF CURSOR;
		cursor_handle		ref_cursor_type;
		l_where                 VARCHAR2(3000):= NULL;
	BEGIN
	       -- Bug 3303486
	       -- Removed the usage of NVL and built the where clause dynamically.
               IF i_whse_code IS NOT NULL THEN
               		l_where := l_where || ' AND :i_whse_code = whse_code ';
	       ELSE
                        l_where := l_where || ' AND :i_whse_code IS NULL ';
               END IF;

                IF i_location IS NOT NULL THEN
                        l_where := l_where || ' AND :i_location = location ';
	        ELSE
                        l_where := l_where || ' AND :i_location IS NULL ';
                END IF;

                IF i_lot_id IS NOT NULL THEN
                        l_where := l_where ||  ' AND :i_lot_id = lot_id ';
	        ELSE
                        l_where := l_where ||  ' AND :i_lot_id IS NULL ';
                END IF;

                IF i_lot_status IS NOT NULL THEN
                        l_where := l_where || ' AND :i_lot_status = lot_status ';
	        ELSE
                        l_where := l_where || ' AND :i_lot_status IS NULL ';
                END IF;

		statement :=
			   'SELECT 1 '
			|| 'FROM ic_loct_inv '
			|| 'WHERE item_id=:i_item_id '
			|| l_where
			|| ' FOR UPDATE NOWAIT ';
		OPEN cursor_handle FOR statement
		USING i_item_id, i_whse_code, i_location, i_lot_id, i_lot_status;

		FETCH cursor_handle INTO row_count;

		IF cursor_handle%NOTFOUND
		THEN
			o_lock_status := NULL;
		ELSE
			o_lock_status := TRUE;
		END IF;

		CLOSE cursor_handle;

		EXCEPTION
		WHEN OTHERS
		THEN
			/*  DBMS_OUTPUT.PUT_LINE('Return Value was '||to_char(SQLCODE)); */
			o_lock_status := FALSE;
	END;

/*  All other procedures are public:  */

/*  Variant #1 Lock all inventory of the specified item */

	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		)
	IS
		i_lock_status	BOOLEAN;
	BEGIN
		GMI_LOCKS.lock_inventory
			( i_item_id     => i_item_id,
                          i_whse_code   => NULL,
                          i_lot_id      => NULL,
                          i_lot_status  => NULL,
                          i_location    => NULL,
                          i_attempts    => 5,
                          o_lock_status => i_lock_status);

		o_lock_status := NVL(i_lock_status, TRUE);
	END;

/*  Variant #2 Lock all inventory of the item in the warehouse specified.   */

	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_whse_mst.whse_code%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		)
	IS
		i_lock_status	BOOLEAN;
	BEGIN
		GMI_LOCKS.lock_inventory
			( i_item_id     => i_item_id,
                          i_whse_code   => i_whse_code,
                          i_lot_id      => NULL,
                          i_lot_status  => NULL,
                          i_location    => NULL,
                          i_attempts    => 5,
                          o_lock_status => i_lock_status);

		o_lock_status := NVL(i_lock_status, TRUE);
	END;

/*  Variant #3 Lock the specified lot(s) of the item in the warehouse.  */

	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_lot_id	IN ic_loct_inv.lot_id%TYPE,
			i_lot_status	IN ic_loct_inv.lot_status%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		)
	IS
		i_lock_status	BOOLEAN;
	BEGIN
		GMI_LOCKS.lock_inventory
			( i_item_id     => i_item_id,
                          i_whse_code   => i_whse_code,
                          i_lot_id      => i_lot_id,
                          i_lot_status  => i_lot_status,
                          i_location    => NULL,
                          i_attempts    => 5,
                          o_lock_status => i_lock_status);

		o_lock_status := NVL(i_lock_status, TRUE);
	END;


/*  Variant #4 Lock inventory in the warehouse and location specified. */

	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_location	IN ic_loct_inv.location%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		)
	IS
		i_lock_status	BOOLEAN;
	BEGIN
		GMI_LOCKS.lock_inventory
			( i_item_id     => i_item_id,
                          i_whse_code   => i_whse_code,
                          i_lot_id      => NULL,
                          i_lot_status  => NULL,
                          i_location    => i_location,
                          i_attempts    => 5,
                          o_lock_status => i_lock_status);

		o_lock_status := NVL(i_lock_status, TRUE);
	END;

/*  Bug 3356201 */
/*  Variant #5 Lock inventory in the warehouse, lot and location specified. */

	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
                        i_lot_id        IN ic_loct_inv.lot_id%TYPE,
			i_location	IN ic_loct_inv.location%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		)
	IS
		i_lock_status	BOOLEAN;
	BEGIN
		GMI_LOCKS.lock_inventory
			( i_item_id     => i_item_id,
                          i_whse_code   => i_whse_code,
                          i_lot_id      => i_lot_id,
                          i_lot_status  => NULL,
                          i_location    => i_location,
                          i_attempts    => 5,
                          o_lock_status => i_lock_status);

		o_lock_status := NVL(i_lock_status, TRUE);
	END;

/*   Variant #6 - Lock inventory in a specific lot and location in the warehouse specified. */

	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_lot_id	IN ic_loct_inv.lot_id%TYPE,
			i_lot_status	IN ic_loct_inv.lot_status%TYPE,
			i_location	IN ic_loct_inv.location%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		)
	IS
		i_lock_status	BOOLEAN;
	BEGIN
		GMI_LOCKS.lock_inventory
			( i_item_id     => i_item_id,
                          i_whse_code   => i_whse_code,
                          i_lot_id      => i_lot_id,
                          i_lot_status  => i_lot_status,
                          i_location    => i_location,
                          i_attempts    => 5,
                          o_lock_status => i_lock_status);

		o_lock_status := NVL(i_lock_status, TRUE);
	END;

/*  Variant #7 - The main code. All of the above public routines call this one and filter the results. */

	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_lot_id	IN ic_loct_inv.lot_id%TYPE,
			i_lot_status	IN ic_loct_inv.lot_status%TYPE,
			i_location	IN ic_loct_inv.location%TYPE,
			i_attempts	IN NUMBER,
			o_lock_status	OUT NOCOPY BOOLEAN
		)
	IS
		retry_count		NUMBER(4);
	BEGIN

		FOR retry_count in 1..i_attempts
		LOOP
			GMI_LOCKS.lock_rows
			( i_item_id     => i_item_id,
                          i_whse_code   => i_whse_code,
                          i_lot_id      => i_lot_id,
                          i_lot_status  => i_lot_status,
                          i_location    => i_location,
                          o_lock_status => o_lock_status);

			IF NVL(o_lock_status,TRUE) = TRUE
			THEN
				RETURN;
			ELSE
				DBMS_LOCK.sleep(1);
			END IF;
		END LOOP;
	END;

END GMI_LOCKS;

/

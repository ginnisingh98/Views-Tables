--------------------------------------------------------
--  DDL for Package GMI_LOCKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_LOCKS" AUTHID CURRENT_USER AS
/*  $Header: GMIULCKS.pls 115.6 2004/01/08 21:14:28 adeshmuk ship $

  This file contains the specification of a package which
  locks rows in ic_loct_inv. It is intended to be used by the allocation
  logic in the OM/OPM integration. At the start of an allocation session
  for a particular item/whse/lot/location, the procedures in this package
  prevent users from accessing the inventory simultaneously whilst it is
  being allocated. This prevents multiple allocation of the same stock and
  eliminates deadlocks between sessions

  For convenience the lock_inventory procedure is overloaded so the same
  routine can be called all the time, just by specifying the desired
  parameter set. Choose from:

 		Item
 		Item, Warehouse
 		Item, Warehouse, Lot, Lot Status
 		Item, Warehouse, Location
 		Item, Warehouse, Lot, Lot Status, Location

  These versions return a status value as follows:

 		TRUE =>  Inventory rows locked successfully
 		FALSE => Inventory rows locked by another user, try later


  Another variant exists for use in situations where the calling code needs
  a bit more control over what's happening. The parameter set here is:

 		Item, Warehouse, Lot, Lot Status, Location, Retries

  where the 'retries' parameter is the number of times to attempt the locking (which
  will take place at 1 second intervals) before giving up.
  For this version of the procedure the return status can be

 		TRUE =>  Inventory rows locked siccessfully
 		FALSE => Inventory rows locked by another user, try later
 		NULL =>  No rows locked because none matched the parameters

  The final (NULL) return could be significant in some situations. The other versions
  of the procedure will return TRUE in this case.



  All calls to this package must specify an item_id at the very least. The other values
  can be passed as NULL. If a warehouse is passed as NULL, locking could take place across
  warehouses. If lot_id is NULL but lot_status is not, all lots of the item with this
  status will be locked, possibly across warehouses if that too is NULL. The possibilities
  are numerous.


  HISTORY

  02-Mar-2000	P.J.Schofield, Oracle UK
 		Package created.
  28-Oct-2002   J.DiIorio 11.5.1J Bug#2643440 - added nocopy.
*/
	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		);
	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_whse_mst.whse_code%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		);
	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_lot_id	IN ic_loct_inv.lot_id%TYPE,
			i_lot_status	IN ic_loct_inv.lot_status%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		);
        /* Bug 3356201 */
        PROCEDURE lock_inventory
                (
                        i_item_id       IN ic_loct_inv.item_id%TYPE,
                        i_whse_code     IN ic_loct_inv.whse_code%TYPE,
                        i_lot_id        IN ic_loct_inv.lot_id%TYPE,
                        i_location      IN ic_loct_inv.location%TYPE,
                        o_lock_status   OUT NOCOPY BOOLEAN
                );
	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_location	IN ic_loct_inv.location%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		);
	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_lot_id	IN ic_loct_inv.lot_id%TYPE,
			i_lot_status	IN ic_loct_inv.lot_status%TYPE,
			i_location	IN ic_loct_inv.location%TYPE,
			o_lock_status	OUT NOCOPY BOOLEAN
		);
	PROCEDURE lock_inventory
		(
			i_item_id	IN ic_loct_inv.item_id%TYPE,
			i_whse_code	IN ic_loct_inv.whse_code%TYPE,
			i_lot_id	IN ic_loct_inv.lot_id%TYPE,
			i_lot_status	IN ic_loct_inv.lot_status%TYPE,
			i_location	IN ic_loct_inv.location%TYPE,
			i_attempts	IN NUMBER,
			o_lock_status	OUT NOCOPY BOOLEAN
		);
END GMI_LOCKS;

 

/

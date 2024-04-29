--------------------------------------------------------
--  DDL for Package INV_RESERVATION_LOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RESERVATION_LOCK_PVT" AUTHID CURRENT_USER AS
/* $Header: INVLRSVS.pls 120.0 2005/06/30 12:18:25 vipartha noship $ */

/**** This package is called to create a user-defined lock on the supply or
the demand document line between the time the line is queried and the
  reservations are being created or modified. Equivalent to the lock on the
  quantity tree for inventory supplies ****/

PROCEDURE lock_supply_demand_record
  (p_organization_id   IN NUMBER
   ,p_inventory_item_id IN NUMBER
   ,p_source_type_id IN NUMBER
   ,p_source_header_id IN NUMBER
   ,p_source_line_id IN NUMBER
   ,p_source_line_detail IN NUMBER
   ,x_lock_handle OUT NOCOPY VARCHAR2
   ,x_lock_status OUT NOCOPY NUMBER);

/**** This package is called to get the lock handle on the supply or
the demand document line when the lock is being created ****/
PROCEDURE get_lock_handle
  (p_lock_name IN VARCHAR2,
   x_lock_handle OUT NOCOPY VARCHAR2);

/**** This package is called to release the lock of supply or
the demand document after the lock has been created and the reservations
  have been successfully created/ modified ****/
PROCEDURE release_lock(p_lock_handle IN VARCHAR2);
END INV_RESERVATION_LOCK_PVT;

 

/
